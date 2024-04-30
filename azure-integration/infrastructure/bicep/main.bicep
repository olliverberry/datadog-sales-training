@description('a comma-deliminated list of the resource groups where resources will be created.')
param resourceGroups string

@description('the password for the admin user.')
@secure()
param adminPassword string

@description('the prefix that all objects will have upon creation.')
param objectPrefix string = 'dd-training'

@description('location for all resources.')
param location string = resourceGroup().location

var vnetAddressPrefix = '10.1.0.0/16'
var vmSubnetAddressPrefix = '10.1.0.0/24'
var vmSubnetName = '${objectPrefix}-subnet0'
var bastionSubnetAddressPrefix = '10.1.1.0/26'
var bastionSubnetName = 'AzureBastionSubnet'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${objectPrefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionSubnetAddressPrefix
        }
      }
      {
        name: vmSubnetName
        properties: {
          addressPrefix: vmSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: '${objectPrefix}-nsg'
  location: location
  properties: {
    securityRules: []
  }
}

resource bastionPublicIP 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${objectPrefix}-bastion-ip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2022-07-01' = {
  name: '${objectPrefix}-bastion'
  location: location
  properties: {
    ipConfigurations: [
      {
        properties: {
          subnet: {
            id: '${virtualNetwork.id}/subnets/${bastionSubnetName}'
          }
          publicIPAddress: {
            id: bastionPublicIP.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
        name: 'bastion-ipconfig'
      }
    ]
  }
}

var vmSubnet = first(filter(virtualNetwork.properties.subnets, subnet => toLower(subnet.name) == toLower(vmSubnetName)))
module vmCreation './vm.bicep' = [for rg in split(resourceGroups, ' | '): {
  name: 'vmcreation'
  scope: resourceGroup(rg)
  params: {
    objectPrefix: objectPrefix
    subnetId: vmSubnet!.id
    networkSecurityGroupId: networkSecurityGroup.id
    adminPassword: adminPassword
    location: location
  }
}]

module containerApp './container.bicep' = {
  name: 'containerapp'
  params: {
    location: location
  }
}
