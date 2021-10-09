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

## Run

Perform full pipeline steps:
```bash
make all
```
**WARNING**: Pay attention that 'make all' command takes time, especially when you choose build artifact action.

### Service install

Service installation can be performed via direct released build or via build from source repository with defined branch and revision. This behaviour can be specified via `SERVICE_INSTALL_TYPE` env variable.

To install / update cloud instances run:
```bash
make artifact
```

## Contibuting

Contributing flow:

1. Create new branch form `main`. Branch name should be in `feature/*` or `hotfix/*` formats;
2. Make and test changes locally;
3. Create PR into `main` branch and wait till all pipelines finished;
4. Request reqview from maintainers.
