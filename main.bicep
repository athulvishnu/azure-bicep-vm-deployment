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

module network 'modules/network.bicep' = {
  name: 'networkModule'
  params: {
    location: location
    environment: environment
  }
}

module vm 'modules/vm.bicep' = {
  name: 'vmModule'
  params: {
    location: location
    environment: environment
    adminUserName: adminUserName
    sshPublicKey: sshPublicKey
    subnetId: network.outputs.subnetId
  }
}

output publicIPAddress string = vm.outputs.publicIPAddress
