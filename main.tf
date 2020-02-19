resource "random_string" "password" {
  length = 32
  special = false
  override_special = "_%@"
}

output "password" {
  value = random_string.password.result
}

output "gcpname" {
  value = google_compute_network.gcp-network.name
}
