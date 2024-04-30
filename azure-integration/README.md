## Azure Integration Training Setup
There are two workflows that can be run in order to create and destory Azure resources needed for Azure Integration Training:
1. `create azure resources`
2. `delete azure resources`

The `create azure resources` workflow runs [setup-azure.ps1](./infrastructure/scripts/setup-azure.ps1) and a [bicep deployment](./infrastructure/bicep/). The `setup-azure.ps1` script creates the following:
* A variable number of Azure Users
* A variable number of Resource Groups
* A Management Group

The `bicep deployment` creates the following:
* A Virtual Network
* A Bastion Host used for connecting to Azure VMs
* A variable number of Azure VMs

## Using the Workflows

## Running the workflows
