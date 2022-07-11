# DataHub Infrastructure

## Prerequisites

The following needs to be installed before running anything

- Terraform
- Powershell
- Azure CLI

## Getting Started

### Setup Environment

To setup a environment's state run

```ps
.\scripts\environment\state.ps1 -Environment <name>
```

To tear down an environment's state run the same command with the `-Destroy` flag

## TODO: Prototype scripts

- [x] spin up/down environments
- [x] spin up/down portal
- [ ] spin up/down project
- [ ] spin up/down features
  - [ ] spin up/down azure storage containers
  - [ ] spin up/down azure databricks
