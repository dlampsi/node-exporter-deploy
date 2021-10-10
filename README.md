# Node exporter deploy

This repository provides set of automation tools to deploy and manage deployments of [Node exporter](https://github.com/prometheus/node_exporter) service.

Automation provides actions to setup cloud based instance(s) and install, configure and test a node exporter into them.

Automation allows to configure node expoter installation via direct released build or via build from source repository with defined branch and revision.

## Developement and run

### Prerequisites

1. [GNU Make 3.81](https://www.gnu.org/software/make/)
2. Depends on the choice of automation run type:
    - [Docker](https://docs.docker.com/get-docker/)
    - [Go 1.16.9](https://golang.org/dl/), [Terraform 1.0.8](https://www.terraform.io), [Ansible 2.9.9](https://www.ansible.com)

Automation can be performed via Docker containers (which is recommended and enabled by default) or via direct tools local run.

You should check your dev environment by running:
```bash
make prechecks
```

## Usage

To get all available automation commands with their descriptions, run:
```bash
make help
```

### TLDR

Common events and commands that you should run on them:

```bash
# Want to check and prepare development env.
make prechecks prepare

# First time run. Want to perform all actions from scratch.
make all

# Cloud infrastructure updates.
make infra

# When node exporter version is updated.
make artifact install

# Node exporter configuration changed.
make config

# Whant only to test deployed services.
make tests
```


### Configuration

Automation uses environment variables as configuration source. Available variables and their descriptions provided in [.dev.env](.dev.env) fie.

To prepare environment for automation, run:

```bash
make prepare
```

For a Docker runner prepare action builds docker images that will be used in some further actions.

## Run

To perform full pipeline steps, run:

> Note that this command takes time, especially when you choose the 'build' action of the artifact.

```bash
make all
```

### Service install type

Node exporter installation can be performed via direct released build or via build from source repository with defined branch and revision.

This behaviour can be specified via `SERVICE_INSTALL_TYPE` env variable.

To make node exporter atrifact with chosed insatll type run:
```bash
make artifact
```

Config example for installation from released build (used by default):

```bash
SERVICE_INSTALL_TYPE=fetch
SERVICE_FETCH_RELEASE=1.2.2
```

Config example for build package from sources:

```bash
SERVICE_INSTALL_TYPE=build
SERVICE_BUILD_BRANCH=branch-name
SERVICE_BUILD_COMMIT=2a737fd69cd80fa8d03fe0df45d7c9ea3579b9ed
```

### Cloud infrastructure

Cloud instances configurations stored into [terraform](terraform/) catalog. Currently automation supports Centos 8 based OS image, with x86 arcitecture artifacts.

You can specify some virtual machine params (like instance name, preset etc) in the [terraform/vars.tf](terraform/vars.tf) file.

To create / updare cloud instances configuration run:

```bash
make infra
```

Terraform apply action also crates inventory file and stores it in the `ansible/` directory for further usage in ansible-playbooks.

### Service configuration

Node exporter configuration stored (and can be changed) in [ansible/group_vars/node_exporter.yml](ansible/group_vars/node_exporter.yml) file.

To update deployed service configuration run:

```bash
make config
```

### Tests

Follow tests available and runs on tests action:
1. Service has been installed
2. Service is running
3. Ensures that service correct version/revision is being used
4. Configuration changes are applied and correct
5. Service listens to necessary ports

To perfrom deployed service tests run:

```bash
make tests
```

## Contibuting

Contributing flow:

1. Create new branch form `main`. Branch name should be in `feature/*` or `hotfix/*` formats;
2. Make and test changes locally;
3. Create PR into `main` branch and wait till all pipelines finished;
4. Request reqview from maintainers.
