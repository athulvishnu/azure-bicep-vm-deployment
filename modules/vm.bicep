var vmSize = 'Standard_B2ats_v2'
var storageAccountType = 'Standard_LRS'

param location string
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string
param adminUserName string
param sshPublicKey string
param subnetId string

resource publicIP 'Microsoft.Network/publicIPAddresses@2025-05-01' = {
  name: '${environment}-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  tags: {
    environment: environment
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2025-05-01' = {
  name: '${environment}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'main'
         properties: {
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
          subnet: {
            id: subnetId
          }
      }
    }
    ]
  }
  tags: {
    environment: environment
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2025-04-01' = {
  name: '${environment}-vm'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
      }
      ]
      }
    osProfile: {
      computerName: '${environment}-vm'
      adminUsername: adminUserName
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUserName}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
      }
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        name: 'os-disk'
        managedDisk: {
          storageAccountType: storageAccountType
        }
      }
      imageReference: {
        offer: 'ubuntu-24_04-lts'
        publisher: 'Canonical'
        sku: 'ubuntu-pro'
        version: 'latest'
      }
    }
  }
  tags: {
    environment: environment
  }
}

output publicIPAddress string = publicIP.properties.ipAddress
