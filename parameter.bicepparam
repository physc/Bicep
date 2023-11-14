using './main.bicep'

param vnetName = {
  Vnet1: {
    name: 'solar-impulse-test'
    addressPrefixes: [ '10.0.0.0/24' ]
  }
  Vnet2: {
    name: 'solar-impulse-acc'
    addressPrefixes: [ '10.1.0.0/24' ]
  }
}
param testsubnets = {
  subnet1: {
    name: 'subnet-01'
    subnetPrefix: [ '10.0.0.0/25' ]
  }
}

param accsubnets = {
  subnet1: {
    name: 'subnet-01'
    subnetPrefix: [ '10.1.0.0/25' ]
  }
  subnet2: {
    name: 'subnet-02'
    subnetPrefix: [ '10.1.0.128/25	' ]
  }
}

param webvmconfig = {
  vmname: 'web-vm'
  vmsize: 'Standard_A2_v2'
  adminusername: 'testadmin'
  publisher: 'Canonical'
  offer: 'UbuntuServer'
  sku: '18.04-LTS'
  version: 'latest'
  osdiskcaching: 'ReadWrite'
  createoption: 'FromImage'

}

param appvmconfig = {
  vmname: 'app-vm'
  vmsize: 'Standard_A2_v2'
  adminusername: 'testadmin'
  publisher: 'Canonical'
  offer: 'UbuntuServer'
  sku: '18.04-LTS'
  version: 'latest'
  osdiskcaching: 'ReadWrite'
  createoption: 'FromImage'

}

param nsgrule = {
  name: 'Allow SSH'
  description: 'Allow SSH'
  protocol: '*'
  sourcePortRange: '*'
  destinationPortRange: '22'
  sourceAddressPrefix: 'sourceAddressPrefix'
  destinationAddressPrefix: 'destinationAddressPrefix'
  access: 'Allow'
  priority: 100
  direction: 'Inbound'

}
