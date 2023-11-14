// Create Subnet for Test Vnet
param testsubnets object

resource testsubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = [for sub in items(testsubnets): {
  name: sub.value.name
  parent: vnet[0]
  properties: {
    addressPrefix: sub.value.subnetPrefix
  }
}]
