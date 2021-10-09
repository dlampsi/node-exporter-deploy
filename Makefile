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
all: prechecks prepare artifact ## Performs full automation cycle: prepares, make artifact


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
		echo "Everyhing is ok"


# -----------------------------------------------------------------------------
.PHONY: prepare prepare-docker prepare-local
prepare: env_info prepare-$(RUNNER) ## Prepare develop environment for actions.
	@echo "Prepared for a '$(RUNNER)' runner"

DOCKER_BUILDER_IMG = node-exporter-builder:local

prepare-docker:
	@docker image build -t $(DOCKER_BUILDER_IMG) -f build/Dockerfile .

prepare-local:
	@echo "Nothing to prepare on local"


# -----------------------------------------------------------------------------
INSTALL_TYPE ?= $(SERVICE_INSTALL_TYPE)

.PHONY: artifact artifact-fetch artifact-build
artifact: env_info artifact-$(INSTALL_TYPE) ## Gets service artifact for further deploy actions.

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

