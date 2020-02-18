resource "random_string" "password" {
  length = 32
  special = false
  override_special = "_%@"
}

output "password" {
  value = random_string.password.result
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

}
resource "azurerm_subnet" "subnet" {
    name           = "GatewaySubnet"
    resource_group_name  = azurerm_resource_group.dfdemo.name
    virtual_network_name = azurerm_virtual_network.dfdemo.name
    address_prefix = "172.16.0.0/24"
  }


resource "azurerm_public_ip" "vpn" {
  name                = "dfdemo_vpn_pubip"
  location            = azurerm_resource_group.dfdemo.location
  resource_group_name = azurerm_resource_group.dfdemo.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "dfdemo_vpn" {
  name                = "test"
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
# resource "azurerm_virtual_network_gateway_connection" "gcp" {
#  name                = "gcp"
#  location            = azurerm_resource_group.dfdemo.location
#  resource_group_name = azurerm_resource_group.dfdemo.name

#  type                       = "IPsec"
#  virtual_network_gateway_id = azurerm_virtual_network_gateway.dfdemo_vpn.id
#  local_network_gateway_id   = azurerm_local_network_gateway.gcp.id

#  shared_key = random_string.password.result
#}


resource "google_compute_vpn_gateway" "target_gateway" {
  name    = "vpn1"
  network = google_compute_network.network1.self_link
}

resource "google_compute_network" "network1" {
  name = "network1"
}

resource "google_compute_address" "vpn_static_ip" {
  name = "vpn-static-ip"
}

resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.target_gateway.self_link
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.target_gateway.self_link
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.target_gateway.self_link
}

resource "google_compute_vpn_tunnel" "tunnel1" {
  name          = "tunnel1"
  peer_ip       = "15.0.0.120"
  shared_secret = "a secret message"

  target_vpn_gateway = google_compute_vpn_gateway.target_gateway.self_link

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
  ]
}

resource "google_compute_route" "route1" {
  name       = "route1"
  network    = google_compute_network.network1.name
  dest_range = "15.0.0.0/24"
  priority   = 1000

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel1.self_link
}
