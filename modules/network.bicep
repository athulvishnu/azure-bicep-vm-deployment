@description('Azure VM Deployment')

param location string
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: '${environment}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes:[
        '10.0.0.0/16'
      ]
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

output subnetId string = subnet.id
