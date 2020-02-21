
resource "google_compute_vpn_gateway" "target_gateway" {
  name    = "vpn1"
  network = google_compute_network.gcp-network.self_link
}

#data "google_compute_subnetwork" "defaultsubnet" {
#  name = "default"
#}

resource "google_compute_network" "gcp-network" {
  name = "gcp-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "gcp-subnet1" {
  name          = "gcp-subnet1"
  ip_cidr_range = "${var.gcp_subnet1_cidr}"
  network       = "${google_compute_network.gcp-network.name}"
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
  peer_ip       = azurerm_public_ip.vpn.ip_address
  shared_secret = random_string.password.result

  target_vpn_gateway = google_compute_vpn_gateway.target_gateway.self_link
  local_traffic_selector = ["${var.gcp_subnet1_cidr}"]

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
    azurerm_public_ip.vpn,
  ]
}

resource "google_compute_route" "route1" {
  name       = "azure"
  network    = google_compute_network.gcp-network.name
  dest_range = azurerm_subnet.netsubnet.address_prefix
  priority   = 1000
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel1.self_link
}
