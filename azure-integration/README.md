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
* An Azure App Service Plan
* A variable number of Azure Web Apps used for log generation

## Using the Workflows
1. Create a fork of this repository.
2. Follow [instructions](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Clinux#use-the-azure-login-action-with-a-service-principal-secret) for creating an Azure Service Principal for authenticating from Github to Azure.\
    **note**: you will need to save the json output of the credentials as we will need them later.
3. [Create a Github Environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#creating-an-environment) and configure the following secrets and variables in the environment:
    * An environment sercret called AZURE_CREDENTIALS with the json output from step 2.
    * An environment secret called AZURE_OWNER_ID. The value supplied to this secret should be the object id of an account owner in the Azure subscription where resources will be created.
    * An environment secret called AZURE_SUBSCRIPTION_ID. This value corresponds to the Azure subscription where resources will be created.
    * An environment secret called AZURE_USER_PASSWORD. This value corresponds to the password that will be used by Azure Users to connect to VMs.
    * An environment variable called AZURE_DOMAIN_NAME. This value corresponds to the Azure domain.
    * An environment variable called AZURE_RESOURCE_GROUP. This value corresponds to the Azure Resource Group where common resources will be created.

## Running the workflows
With the Github Environment created, we can start to use the actions to deploy our Azure resources. Navigate to the `Actions` tab in your forked repository and click on the `create azure resources` workflow. Once on the `create azure resources` workflow page, select `Run workflow` and choose the Github Environment previously created. Additionally, specify the number of Azure Users to create.

When you no longer need the resources in Azure, run the `delete azure resources` workflow targeting the Github Environment that was used when running the `create azure resources` workflow.