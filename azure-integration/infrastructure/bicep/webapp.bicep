@description('the tags to apply to created resources.')
param tags object = {}

@description('Specifies the location for all resources.')
param location string = resourceGroup().location

@description('the name of the app service plan.')
param serverFarmName string = 'log-generator-asp-${uniqueString(resourceGroup().id)}'

@description('the name of the web app.')
param webAppName string = 'log-generator-app-${uniqueString(resourceGroup().id)}'

@description('the sku for the app service plan.')
param sku string = 'Basic'

@description('the sku code for the app service plan.')
param skuCode string = 'B1'

@description('log generator image.')
param logGeneratorImage string = 'smehrens/log-generator-api:0.0.3'

resource serverFarm 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: serverFarmName
  location: location
  tags: tags
  sku: {
    tier: sku
    name: skuCode
  }
  kind: 'linux'
}

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  tags: tags
  properties: {
    siteConfig: {
      linuxFxVersion: 'DOCKER|${logGeneratorImage}'
      healthCheckPath: '/api/dogs'
      alwaysOn: true
    }
    publicNetworkAccess: 'Disabled'
    serverFarmId: serverFarm.id
  }
}
