resource "azurerm_resource_group" "dfdemo" {
  name     = "dfdemo"
  location = "East US"
}

resource "azurerm_virtual_network" "dfdemo" {
  name                = "dfdemo_network"
  location            = azurerm_resource_group.dfdemo.location
  resource_group_name = azurerm_resource_group.dfdemo.name
  address_space       = ["${var.az_network_cidr}"]

}
resource "azurerm_subnet" "subnet" {
    name           = "GatewaySubnet"
    resource_group_name  = azurerm_resource_group.dfdemo.name
    virtual_network_name = azurerm_virtual_network.dfdemo.name
    address_prefix =  var.az_gatewaysubnet_cidr
  }

resource "azurerm_subnet" "netsubnet" {
    name           = "network1Subnet"
    resource_group_name  = azurerm_resource_group.dfdemo.name
    virtual_network_name = azurerm_virtual_network.dfdemo.name
    address_prefix =  var.az_subnet1_cidr
  }
  
resource "azurerm_public_ip" "vpn" {
  name                = "dfdemo_vpn_pubip"
  location            = azurerm_resource_group.dfdemo.location
  resource_group_name = azurerm_resource_group.dfdemo.name
  allocation_method = "Dynamic"
}

data "azurerm_public_ip" "vpn" {
  name                = azurerm_public_ip.vpn.name
  resource_group_name = azurerm_public_ip.vpn.resource_group_name
  depends_on = [azurerm_public_ip.vpn]
}

output "public_ip_address" {
  value = data.azurerm_public_ip.vpn.ip_address
}

resource "azurerm_virtual_network_gateway" "dfdemo_vpn" {
  name                = "dfdemo_az_gateway"
  location            = azurerm_resource_group.dfdemo.location
  resource_group_name = azurerm_resource_group.dfdemo.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet.id
  }
}

resource "azurerm_local_network_gateway" "gcp" {
  name                = "dfdemo_gcp_gateway"
  resource_group_name = azurerm_resource_group.dfdemo.name
  location            = azurerm_resource_group.dfdemo.location
  gateway_address     = google_compute_address.vpn_static_ip.address
  address_space       = ["${var.gcp_subnet1_cidr}"]
}

resource "azurerm_virtual_network_gateway_connection" "gcp" {
  name                = "dfdemo_gcp_connection"
  location            = azurerm_resource_group.dfdemo.location
  resource_group_name = azurerm_resource_group.dfdemo.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.dfdemo_vpn.id
  local_network_gateway_id   = azurerm_local_network_gateway.gcp.id

  shared_key = random_string.password.result
}

#13.90.101.114