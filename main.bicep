@description('Azure VM Deployment')

param location string
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string
param adminUserName string
param sshPublicKey string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: '${environment}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes:['10.0.0.0/16']
  }
}
tags: {
  environment: environment
}
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' = {
  name: '${environment}-subnet'
  parent: virtualNetwork
  properties: {
    addressPrefix: '10.0.1.0/24'
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
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
            id: subnet.id
          }
      }
    }
    ]
  }
  tags: {
    environment: environment
  }
}

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

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2025-05-01' = {
  name: '${environment}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-ssh'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 1000
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
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
      vmSize: 'Standard_B2ats_v2'
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
          storageAccountType: 'Standard_LRS'
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
