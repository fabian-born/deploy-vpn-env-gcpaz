az_gatewaysubnet_cidr   = "172.16.64.0/24"
az_subnet1_cidr         = "172.16.66.0/24"
az_network_cidr         = "172.16.64.0/22"
gcp_subnet1_cidr        = "172.16.128.0/24"
gcp_network_cidr        = "172.16.128.0/22"

###################################################
image_publisher         = "netapp"                                       # image publisher
image_offer             = "netapp-oncommand-cloud-manager"               # image offer
image_sku               = "occm-byol"                                    # image sku
image_version           = "latest"                                       # image version
###################################################
managed_disk_type       = "Premium_LRS"                                  # os root disk type
vm_admin_user           = "admin"                                             # admin user name
vm_admin_password       = "netapp123!NetApp123!"                                             # admin password
instance_type           = "Standard_DS1_v2"                              # instance type             
###################################################
gcp_enabled             = "true"
vpn_enabled             = "false"
ansible_provision_file  = "./ansible/occm_setup.yaml"


# refresh_token           = ""   # private refresh token                               
# client_id               = ""   # default auth0 id
# portal_user_name        = ""   # user email

