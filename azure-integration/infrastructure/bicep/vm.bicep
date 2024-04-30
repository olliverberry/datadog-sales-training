@description('the current vm being created.')
param index int

@description('object prefix.')
param objectPrefix string

@description('subnet id.')
param subnetId string

@description('the password of the admin user for logging into the vm.')
@secure()
param adminPassword string

@description('network security group id.')
param networkSecurityGroupId string

@description('location.')
param location string = resourceGroup().location

@description('the size of the vm to create.')
param vmSize string = 'Standard_B2s'

@description('the username for logging into the vm.')
param adminUsername string = 'dd-sales-training'

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: '${objectPrefix}-ni-${index}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: '${objectPrefix}-ipconfig-${index}'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    networkSecurityGroup: {
      id: networkSecurityGroupId
    }
  }
}

var vmName = toLower(take('${objectPrefix}-vm${index}', 15))
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-core-smalldisk-g2'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
  }
}
