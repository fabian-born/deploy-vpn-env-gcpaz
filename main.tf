
provider "azurerm" {
    subscription_id = "04e10b5f-7248-43c5-a56c-7fce5c485f28"
    tenant_id       = "4b0911a0-929b-4715-944b-c03745165b3a"
}

resource "azurerm_resource_group" "dfdemo" {
  name     = "dfdemo"
  location = "East US"
}

resource "azurerm_virtual_network" "dfdemo" {
  name                = "dfdemo_network"
  location            = azurerm_resource_group.dfdemo.location
  resource_group_name = azurerm_resource_group.dfdemo.name
  address_space       = ["172.16.0.0/16"]

  subnet {
    name           = "GatewaySubnet"
    address_prefix = "172.16.0.0/24"
  }
  subnet {
    name           = "dfdemo_network_pub"
    address_prefix = "172.16.1.0/24"
  }
}

