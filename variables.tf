variable gcp_network_cidr       {}
variable gcp_subnet1_cidr       {}
variable az_network_cidr        {}
variable az_gatewaysubnet_cidr  {}
variable az_subnet1_cidr  {}

variable "image_publisher"        {}
variable "image_offer"            {}
variable "image_sku"              {}
variable "image_version"          {}
variable "managed_disk_type"      {}
variable "vm_admin_user"          {}
variable "vm_admin_password"      {}
variable "instance_type"          {}

variable "ansible_provision_file" {}
variable "refresh_token"          {}
variable "client_id"              {}
variable "portal_user_name"       {}
variable "auth0_domain"           {} 

variable "gcp_enabled" {}
variable "vpn_enabled" {type = bool}
