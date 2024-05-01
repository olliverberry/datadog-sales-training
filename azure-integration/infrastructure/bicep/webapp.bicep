@description('index of the web app being created.')
param index int

@description('the id of the app service plan')
param serverFarmId string

@description('the tags to apply to created resources.')
param tags object = {}

@description('Specifies the location for all resources.')
param location string = resourceGroup().location

@description('the name of the web app.')
param webAppName string = 'log-generator-${uniqueString(resourceGroup().id)}-app'

@description('log generator image.')
param logGeneratorImage string = 'index.docker.io/smehrens/log-generator-api:1.0.0'

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: '${webAppName}-${index}'
  location: location
  tags: tags
  properties: {
    siteConfig: {
      linuxFxVersion: 'DOCKER|${logGeneratorImage}'
      healthCheckPath: '/api/dogs'
      alwaysOn: true
    }
    publicNetworkAccess: 'Disabled'
    serverFarmId: serverFarmId
  }
}
