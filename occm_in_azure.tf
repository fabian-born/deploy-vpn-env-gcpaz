# Configure the Microsoft Azure Provider

# Create a resource group
resource "azurerm_resource_group" "occmgroup" {
  name       = azurerm_resource_group.dfdemo.name
  location   = azurerm_resource_group.dfdemo.location
}
# Create a resource group
data "azurerm_resource_group" "occmgroup" {
  name     = azurerm_resource_group.occmgroup.name
}

# Create a virtual network within the resource group

# Create a virtual network within the resource group
data "azurerm_virtual_network" "occmvnet" {
  name                = azurerm_virtual_network.dfdemo.name
  resource_group_name = azurerm_resource_group.dfdemo.name
}

data "azurerm_subnet" "occmsubnet" {
  name                = azurerm_subnet.netsubnet.name
  resource_group_name = azurerm_resource_group.dfdemo.name
  virtual_network_name = data.azurerm_virtual_network.occmvnet.name
}


# Create public IPs
resource "azurerm_public_ip" "occmpublicip" {
    name                         = "OccmPublicIPDEMO111110"
    location                     = "${data.azurerm_resource_group.occmgroup.location}"
    resource_group_name          = "${data.azurerm_resource_group.occmgroup.name}"
    allocation_method            = "Dynamic"

    tags = {
        environment = "OCCM Demo"
    }
}

data "azurerm_public_ip" "occmip" {
    name                = "${azurerm_public_ip.occmpublicip.name}"
    resource_group_name = "${data.azurerm_resource_group.occmgroup.name}"
    depends_on           = [azurerm_virtual_machine.occmvm]
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "occmnsg" {
    name                = "OccmNetworkSecurityGroupDEMO111110"
    location            = "${data.azurerm_resource_group.occmgroup.location}"
    resource_group_name = "${data.azurerm_resource_group.occmgroup.name}"

    security_rule {
        name                       = "HTTP"
        priority                   = 1010
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTPS"
        priority                   = 1020
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    
    security_rule {
        name                       = "SSH"
        priority                   = 1030
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }    

    tags = {
        environment = "OCCM Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "occmnic" {
    name                      = "OccmNICDEMO111110"
    location                  = azurerm_resource_group.dfdemo.location
    resource_group_name       = "${data.azurerm_resource_group.occmgroup.name}"
    network_security_group_id = "${azurerm_network_security_group.occmnsg.id}"

    ip_configuration {
        name                          = "myNicConfigurationDEMO111110"
        subnet_id                     = "${data.azurerm_subnet.occmsubnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.occmpublicip.id}"
    }

    tags = {
        environment = "OCCM Demo"
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "occmvm" {
    name                          = "OccmVmDEMO111110"
    location                      = azurerm_resource_group.dfdemo.location
    resource_group_name           = "${data.azurerm_resource_group.occmgroup.name}"
    network_interface_ids         = ["${azurerm_network_interface.occmnic.id}"]
    vm_size                       = "${var.instance_type}"
    delete_os_disk_on_termination = "true"

    storage_os_disk {
        name              = "OccmOsDiskDEMO111110"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "${var.managed_disk_type}"
    }

    storage_image_reference {
        publisher = "${var.image_publisher}"
        offer     = "${var.image_offer}"
        sku       = "${var.image_sku}"
        version   = "${var.image_version}"
    }

    plan {
        name = "${var.image_sku}"
        product = "${var.image_offer}"
        publisher = "${var.image_publisher}"
    }    

    # User/Passowrd Authentication
    os_profile {
        computer_name  = "occmvm"
        admin_username = "testadmin"
        admin_password = "Password1234!"
    }
    
    os_profile_linux_config {
        disable_password_authentication = false
    }    

    tags = {
        environment = "OCCM Demo"
    }

}


#resource "null_resource" "ansible-provision" {
#
#  provisioner "local-exec" {
#        command =<<EOF
#        ansible-playbook '${var.ansible_provision_file}' --extra-vars 'occm_ip=${data.azurerm_public_ip.occmip.ip_address} \
#                                                                        client_id=${var.client_id} \
#                                                                        auth0_domain=${var.auth0_domain} \
#                                                                        refToken=${var.refresh_token} \
#                                                                        portalUserName=${var.portal_user_name}'
#        EOF
#  }
#}  