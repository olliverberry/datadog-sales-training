param objectPrefix string

param bastionSubnetName string

param vnetId string

param tags object = {}

param location string = resourceGroup().location

resource bastionPublicIP 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${objectPrefix}-bastion-ip'
  location: location
  tags: tags
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
  tags: tags
  properties: {
    ipConfigurations: [
      {
        properties: {
          subnet: {
            id: '${vnetId}/subnets/${bastionSubnetName}'
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
