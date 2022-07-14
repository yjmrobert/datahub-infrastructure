# DataHub Infrastructure

## Prerequisites

The following needs to be installed before running anything

- Terraform
- Powershell
- Azure CLI

## Getting Started

In order to remotely store the state for terraform you need a remote storage container per environment. To setup a environment's remote state, run the following command:

```ps
.\scripts\environment\terraform_state.ps1 -Environment <environment>
```

> _Note: to destroy the remote state, be sure to destroy all dependencies first and then append the `-Destroy` flag to the command_

Once that is setup, you can deploy the portal infrastructure using the following command:

```ps
.\scripts\environment\datahub_portal.ps1 -Environment <environment>
```

> _Note: to destory the portal, append the `-Destroy` flag to the command_

To create a new project, run the following command:

```ps
.\scripts\project\datahub_project.ps1 -Environment <environment> -ProjectAcronym <acronym>
```

> _Note: to destroy the project, append the `-Destroy` flag to the command_

## TODO: Prototype scripts

- [x] spin up/down environments
- [x] spin up/down portal
- [x] spin up/down project
- [ ] spin up/down features
  - [ ] spin up/down azure storage containers
  - [ ] spin up/down azure databricks
