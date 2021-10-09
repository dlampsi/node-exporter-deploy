.DEFAULT_GOAL := help

.PHONY: help
help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Using .env file if exists
ifneq (,$(wildcard ./.env))
    include .env
    export
    ENV_FILE_PARAM = --env-file ./.env
	EXT_ENV_FILE_PARAM = --env-file ../.env
endif

# Run dir path
PWD ?= $(shell pwd)

# Actions runner type: docker or local.
RUNNER ?= docker

SSH_ACCESS_KEY ?= $(DEPLOY_KEY_PATH)

.PHONY: all
all: prechecks prepare artifact infra install ## Performs full automation cycle: prepares, make artifact, deploys cloud infrastructure, installs app and run tests.

.PHONY: info
env_info: ## Prints current env info.
	@echo "Using '$(RUNNER)' runner...\n"

.PHONY: env_file
env_file:
	@cp -n .dev.env .env 2>/dev/null || :

# -----------------------------------------------------------------------------
.PHONY: prechecks
prechecks: env_info ## Performs pre-checks for a local development environment.
	@bash scripts/prechecks.sh $(RUNNER) && \
		echo "Prechecks are successful"


# -----------------------------------------------------------------------------
.PHONY: prepare prepare-docker prepare-local
prepare: env_info prepare-$(RUNNER) ## Prepares develop environment for further actions.
	@echo "Prepared for a '$(RUNNER)' runner"

DOCKER_BUILDER_IMG = node-exporter-builder:local
DOCKER_DEPLOYER_IMG = node-exporter-deployer:local

prepare-docker:
	@docker image build -t $(DOCKER_BUILDER_IMG) -f build/Dockerfile . \
		&& docker image build -t $(DOCKER_DEPLOYER_IMG) -f ansible/Dockerfile .\

prepare-local:
	@echo "Nothing to prepare on local"


# -----------------------------------------------------------------------------
INSTALL_TYPE ?= $(SERVICE_INSTALL_TYPE)

.PHONY: artifact artifact-fetch artifact-build
artifact: env_info artifact-$(INSTALL_TYPE) ## Downloads or builds service artifact for further deploy actions.

ARTIFACT_IMG_ARGS = $(ENV_FILE_PARAM) -v $(PWD)/.artifacts:/app/.artifacts
ARTIFACT_SCRIPT = scripts/aritfact.sh

.PHONY: artifact-fetch-docker artifact-fetch-local
artifact-fetch: artifact-fetch-$(RUNNER)

artifact-fetch-docker:
	@docker run --rm $(ARTIFACT_IMG_ARGS) $(DOCKER_BUILDER_IMG) fetch

artifact-fetch-local:
	@bash $(ARTIFACT_SCRIPT) fetch

.PHONY: artifact-build-docker artifact-build-local
artifact-build: artifact-build-$(RUNNER)

artifact-build-docker:
	@docker run --rm $(ARTIFACT_IMG_ARGS) $(DOCKER_BUILDER_IMG) build

artifact-build-local:
	@bash $(ARTIFACT_SCRIPT) build

# -----------------------------------------------------------------------------
.PHONY: infra infra-docker infra-local
infra: env_info infra-$(RUNNER) ## Deploys or update cloud infrastructure.

TERRAFORM_IMG := hashicorp/terraform:1.0.8
TERRAFORM_IMG_ARGS = -v ${PWD}/terraform:/deploy/terraform -v ${PWD}/ansible:/deploy/ansible -v $(SSH_ACCESS_KEY):/tmp/id_rsa
TERRAFORM_CHRID_ARG = -chdir=/deploy/terraform

.PHONY: infra-docker-prepare infra-docker-check
infra-docker: infra-docker-prepare
	@cd terraform && docker run --rm $(EXT_ENV_FILE_PARAM) $(TERRAFORM_IMG_ARGS) $(TERRAFORM_IMG) $(TERRAFORM_CHRID_ARG) apply plan

infra-docker-prepare: infra-docker-check
	@docker run --rm $(ENV_FILE_PARAM) $(TERRAFORM_IMG_ARGS) $(TERRAFORM_IMG) $(TERRAFORM_CHRID_ARG) plan -out=plan -var="private_ssh_key=/tmp/id_rsa"

infra-docker-check:
	@docker run --rm $(ENV_FILE_PARAM) $(TERRAFORM_IMG_ARGS) $(TERRAFORM_IMG) $(TERRAFORM_CHRID_ARG) init && \
		docker run --rm $(ENV_FILE_PARAM) $(TERRAFORM_IMG_ARGS) $(TERRAFORM_IMG) $(TERRAFORM_CHRID_ARG) validate

.PHONY: infra-local-prepare infra-local-check
infra-local: infra-local-prepare
	@cd terraform && terraform apply plan

infra-local-prepare: infra-local-check
	@cd terraform && terraform plan -out=plan -var="private_ssh_key=$(SSH_ACCESS_KEY)"

infra-local-check:
	@cd terraform && terraform init && terraform validate


# -----------------------------------------------------------------------------
ANSIBLE_IMG_ARGS = $(ENV_FILE_PARAM) -v ${PWD}/ansible:/app/ansible -v $(SSH_ACCESS_KEY):/home/ansible/.ssh/id_rsa -v $(PWD)/.artifacts:/app/.artifacts
ANSIBLE_ARGS = -e ansible_ssh_private_key_file=$(SSH_ACCESS_KEY)

.PHONY: install install-docker install-local
install: env_info install-$(RUNNER) tests ## Installs the service to infrastructure hosts and perform tests.

install-docker:
	@docker run --rm $(ANSIBLE_IMG_ARGS) $(DOCKER_DEPLOYER_IMG) playbooks/install.yml $(ANSIBLE_ARGS)

install-local:
	@cd ansible && ansible-playbook playbooks/install.yml $(ANSIBLE_ARGS)


# -----------------------------------------------------------------------------
.PHONY: configure configure-docker configure-local
configure: env_info configure-$(RUNNER) tests ## Configures deployed services.

ANSIBLE_CONFIGURE_CMD = playbooks/configure.yml $(ANSIBLE_ARGS)

configure-docker:
	@docker run --rm $(ANSIBLE_IMG_ARGS) $(DOCKER_DEPLOYER_IMG) $(ANSIBLE_CONFIGURE_CMD)

configure-local:
	@cd ansible && ansible-playbook $(ANSIBLE_CONFIGURE_CMD)


# -----------------------------------------------------------------------------
.PHONY: tests tests-docker tests-local
tests: env_info tests-$(RUNNER) ## Testing existing deployments.

ANSIBLE_TESTS_CMD = playbooks/tests.yml $(ANSIBLE_ARGS) -e node_exporter_version=$(SERVICE_FETCH_RELEASE) -e node_exporter_release_branch=$(SERVICE_BUILD_BRANCH) -e node_exporter_release_commit=$(SERVICE_BUILD_COMMIT)

tests-docker:
	@docker run --rm $(ANSIBLE_IMG_ARGS) $(DOCKER_DEPLOYER_IMG) $(ANSIBLE_TESTS_CMD)

tests-local:
	@cd ansible && ansible-playbook $(ANSIBLE_TESTS_CMD)


# -----------------------------------------------------------------------------
.PHONY: ansible-tests ansible-tests-docker ansible-tests-local
ansible-tests: ansible-tests-$(RUNNER)

ansible-tests-docker:
	@docker run --rm $(ANSIBLE_IMG_ARGS) $(DOCKER_DEPLOYER_IMG) playbooks/install.yml $(ANSIBLE_ARGS) --syntax-check && \
		docker run --rm $(ANSIBLE_IMG_ARGS) $(DOCKER_DEPLOYER_IMG) $(ANSIBLE_CONFIGURE_CMD) --syntax-check && \
		docker run --rm $(ANSIBLE_IMG_ARGS) $(DOCKER_DEPLOYER_IMG) $(ANSIBLE_TESTS_CMD) --syntax-check

ansible-tests-local:
	@cd ansible && ansible-playbook $(ANSIBLE_CONFIGURE_CMD) --syntax-check && \
		ansible-playbook playbooks/install.yml $(ANSIBLE_ARGS) --syntax-check && \
		ansible-playbook $(ANSIBLE_TESTS_CMD) --syntax-check
