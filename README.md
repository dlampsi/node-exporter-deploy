# Node exporter deploy

This repository provides set of automation tools to deploy and manage deployments of [Node exporter](https://github.com/prometheus/node_exporter) service.

Automation provides actions to setup cloud based instance(s) and install, configure and test a Node exporter into them.

Automation allows to configure Node expoter installation via direct released build or via build from source repository with defined branch and revision.

## Developement and run

### Prerequisites

1. [GNU Make](https://www.gnu.org/software/make/)
2. Depends on the choice of automation run type:
    - [Docker-CE](https://www.docker.com/get-started)
    - [Go 1.16.8](https://golang.org/dl/), [Terraform 1.0.8](https://www.terraform.io), [Ansible 2.9.9](https://www.ansible.com)

Automation can be performed via Docker containers (which is recommended and enabled by default) or via direct tools local run.

You should check your dev environment via:
```bash
make prechecks
```

## Usage

To get all available pipeline commands with their descriptions use:
```bash
make help
```

### Configuration

Automation configured via environent vaiables. Required variables and their descriptions provided in [.dev.env](.dev.env) fie.

To prepare environment for automation run use command:

```bash
make prepare
```

For a Docker runner prepare action builds docker images that will be used in some further actions.

## Run

Perform full pipeline steps:
```bash
make all
```
**WARNING**: Pay attention that `make all` command takes time, especially when you choose build artifact action.

### Service install

Service installation can be performed via direct released build or via build from source repository with defined branch and revision. This behaviour can be specified via `SERVICE_INSTALL_TYPE` env variable.

To install / update cloud instances run:
```bash
make artifact
```

Config example for installation from released build:

```bash
SERVICE_INSTALL_TYPE=fetch
SERVICE_FETCH_RELEASE=1.2.2
```

Config example for build package from sources:

```bash
SERVICE_INSTALL_TYPE=build
SERVICE_BUILD_BRANCH=dummy
SERVICE_BUILD_COMMIT=2a737fd69cd80fa8d03fe0df45d7c9ea3579b9ed
```


### Infrastructure

Cloud instances configurations stored into [terraform](terraform/) catalog. Currently automation supports Centos 8 based OS image, with x86 arcitecture artifacts.

You can specify some virtual machine params (like instance name, preset etc) in the [terraform/vars.tf](terraform/vars.tf) file.

To create / updare cloud instances configuration run:

```bash
make infra
```

Terraform apply actions also crates inventory file and stores it in the `ansible/` directory for further usage in ansible-playbooks.

### Service configuration

Node exporter configuration stored (and can be changed) in [ansible/group_vars/all.yml](ansible/group_vars/all.yml) file.

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
