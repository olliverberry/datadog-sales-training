@description('a comma-deliminated list of the resource groups where resources will be created.')
param resourceGroups string

@description('the password for the admin user.')
@secure()
param adminPassword string

@description('the prefix that all objects will have upon creation.')
param objectPrefix string = 'dd-az-training'

@description('location for all resources.')
param location string = resourceGroup().location

var subnetAddressPrefix = '10.1.0.0/24'
var addressPrefix = '10.1.0.0/16'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${objectPrefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: virtualNetwork
  name: '${objectPrefix}-subnet0'
  properties: {
    addressPrefix: subnetAddressPrefix
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: '${objectPrefix}-nsg'
  location: location
  properties: {
    securityRules: []
  }
}

module vmCreation './vm.bicep' = [for rg in split(resourceGroups, ' | '): {
  name: 'vmcreation'
  scope: resourceGroup(rg)
  params: {
    objectPrefix: objectPrefix
    subnetId: subnet.id
    networkSecurityGroupId: networkSecurityGroup.id
    adminPassword: adminPassword
    location: location
  }
}]
