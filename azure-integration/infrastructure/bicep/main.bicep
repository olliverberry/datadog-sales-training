@description('a comma-deliminated list of the resource groups where resources will be created.')
param resourceGroups string

@description('the password for the admin user.')
@secure()
param adminPassword string

@description('the prefix that all objects will have upon creation.')
param objectPrefix string = 'datadog-sales-training'

@description('location for all resources.')
param location string = resourceGroup().location

var subnetAddressPrefix = '10.1.0.0/24'
var addressPrefix = '10.1.0.0/16'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'datadog-sales-training-vnet'
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
  name: 'datadog-sales-training-subnet0'
  properties: {
    addressPrefix: subnetAddressPrefix
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: 'datadog-sales-training-nsg'
  location: location
  properties: {
    securityRules: []
  }
}

module vmCreation './vm.bicep' = [for (rg, i) in split(resourceGroups, ','): {
  name: 'vmcreation/${rg}'
  scope: resourceGroup(rg)
  params: {
    index: i
    objectPrefix: objectPrefix
    subnetId: subnet.id
    networkSecurityGroupId: networkSecurityGroup.id
    adminPassword: adminPassword
  }
}]
