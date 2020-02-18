resource "random_string" "password" {
  length = 32
  special = false
  override_special = "_%@"
}

output "password" {
  value = random_string.password.result
}
