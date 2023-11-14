// Create resourcegroup for deployment

param vnetName object
param testsubnets object
param accsubnets object
param webvmconfig object
param appvmconfig object
var webinstances = 2
var appinstances = 2
param nsgrule object

// Create Virtual Network 

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = [for vnets in items(vnetName): {
  name: vnets.value.name
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: vnets.value.addressPrefixes
    }
  }
}]

// Create Subnet for Test Vnet

resource testsubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = [for sub in items(testsubnets): {
  name: sub.value.name
  parent: vnet[0]
  properties: {
    addressPrefix: sub.value.subnetPrefix
  }
}]

// Create Subnet for Acc Vnet

resource accsubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = [for accsub in items(accsubnets): {
  name: accsub.value.name
  parent: vnet[1]
  properties: {
    addressPrefix: accsub.value.subnetPrefix
    networkSecurityGroup: networkSecurityGroup[1].name
  }
}]

// Create Network Interface for Web VM
resource webnetworkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = [for i in range(0, webinstances): {
  name: '${webvmconfig.vmname}-nic${i}'
  dependsOn: accsubnet
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: '${webvmconfig.vmname}-nic${i}'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: accsubnet[0].id
          }
        }
      }
    ]
  }
}]

// Create VM in acc subnet and associate NSG and security rule to access the same.

resource webVM 'Microsoft.Compute/virtualMachines@2020-12-01' = [for i in range(0, webinstances): {
  name: '${webvmconfig.vmname}${i}'
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: webvmconfig.vmsize
    }
    osProfile: {
      computerName: '${webvmconfig.vmname}${i}'
      adminUsername: webvmconfig.adminusername
      adminPassword: 'adminPassword'
    }
    storageProfile: {
      imageReference: {
        publisher: webvmconfig.publisher
        offer: webvmconfig.offer
        sku: webvmconfig.sku
        version: webvmconfig.version
      }
      osDisk: {
        name: '${webvmconfig.vmname}${i}'
        caching: webvmconfig.osdiskcaching
        createOption: webvmconfig.createoption
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${webvmconfig.vmname}-nic${i}')
        }
      ]
    }

  }
}
]

// Create network security Group and assign it to subnet

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = [for vnets in items(vnetName): {
  name: '${vnets.value.name}-nsg'
  location: resourceGroup().location
  dependsOn: vnet

}]

// Network secruity rule and attach it to nsg

resource networkSecurityGroupSecurityRule 'Microsoft.Network/networkSecurityGroups/securityRules@2019-11-01' = {
  name: concat(networkSecurityGroup[1].name, '/', nsgrule.name)
  dependsOn: networkSecurityGroup
  properties: {
    description: nsgrule.description
    protocol: nsgrule.protocol
    sourcePortRange: nsgrule.sourcePortRange
    destinationPortRange: nsgrule.destinationPortRange
    sourceAddressPrefix: nsgrule.sourceAddressPrefix
    destinationAddressPrefix: nsgrule.destinationAddressPrefix
    access: nsgrule.access
    priority: nsgrule.priority
    direction: nsgrule.direction
  }

}

// Create Network Interface for App VM
resource appnetworkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = [for i in range(0, appinstances): {
  name: '${appvmconfig.vmname}-nic${i}'
  dependsOn: accsubnet
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: '${appvmconfig.vmname}-nic${i}'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: accsubnet[1].id
          }
        }
      }
    ]
  }
}]

// Create App VM

resource AppVM 'Microsoft.Compute/virtualMachines@2020-12-01' = [for i in range(0, appinstances): {
  name: '${appvmconfig.vmname}${i}'
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: appvmconfig.vmsize
    }
    osProfile: {
      computerName: '${appvmconfig.vmname}${i}'
      adminUsername: appvmconfig.adminusername
      adminPassword: 'adminPassword'
    }
    storageProfile: {
      imageReference: {
        publisher: appvmconfig.publisher
        offer: appvmconfig.offer
        sku: appvmconfig.sku
        version: appvmconfig.version
      }
      osDisk: {
        name: '${appvmconfig.vmname}${i}'
        caching: appvmconfig.osdiskcaching
        createOption: appvmconfig.createoption
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${appvmconfig.vmname}-nic${i}')
        }
      ]
    }

  }
}
]
