// Create Virtual Network 

param vnetName object

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = [for vnets in items(vnetName): {
  name: vnets.value.name
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: vnets.value.addressPrefixes
    }
  }
}]

output arrayOutput array = vnet
