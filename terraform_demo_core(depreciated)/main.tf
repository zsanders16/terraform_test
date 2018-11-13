#######################################################################################################################
# Core Infrastructure

# Configure the Azure Provider
provider "azurerm" {}

# Create a resource group
resource "azurerm_resource_group" "main_rg" {
  name     = "main_rg"
  location = "${var.location}"
}

# Create a virtual network within the resource group and subnets
resource "azurerm_virtual_network" "main-network" {
  name                = "main-network"
  address_space       = ["${var.vnet_address_space}"]
  location            = "${azurerm_resource_group.main_rg.location}"
  resource_group_name = "${azurerm_resource_group.main_rg.name}"
}

// resource "azurerm_subnet" "subnet1" {
//   name                 = "subnet1"
//   resource_group_name  = "${azurerm_resource_group.main_rg.name}"
//   virtual_network_name = "${azurerm_virtual_network.main-network.name}"
//   address_prefix       = "${var.subnet1}"
// }

resource "azurerm_subnet" "admin_subnet" {
  name                 = "admin_subnet"
  resource_group_name  = "${azurerm_resource_group.main_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.main-network.name}"
  address_prefix       = "${var.admin_subnet}"
}

#######################################################################################################################
# NSGs

resource "azurerm_network_security_group" "tfjboxnsg" {
  name                = "jumpboxnsg"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.main_rg.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"    # add source addr
    destination_address_prefix = "*"
  }

  tags {
    environment = "admin"
  }
}

resource "azurerm_network_security_group" "serversnsg" {
  name                = "servernsg"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.main_rg.name}"

  security_rule {
    name                       = "SSH_VNET"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  tags {
    environment = "admin"
  }
}

## resource "azurerm_network_security_group" "consul" {
##   name = "${var.cluster_name}"
##   location = "${var.location}"
##   resource_group_name = "${azurerm_resource_group.main_rg.name}"
## }## module "security_group_rules" {
##   source = "../modules/consul-nsg-rules"##   security_group_name = "${azurerm_network_security_group.consul.name}"
##   resource_group_name = "${azurerm_resource_group.main_rg.name}"
##   allowed_inbound_cidr_blocks = ["${var.allowed_inbound_cidr_blocks}"]##   server_rpc_port = "${var.server_rpc_port}"
##   cli_rpc_port    = "${var.cli_rpc_port}"
##   serf_lan_port   = "${var.serf_lan_port}"
##   serf_wan_port   = "${var.serf_wan_port}"
##   http_api_port   = "${var.http_api_port}"
##   dns_port        = "${var.dns_port}"
## }


#######################################################################################################################
# Public IPs

resource "azurerm_public_ip" "jumpbox_ip" {
  name                          = "jumpbox_public_ip"
  location                      = "${var.location}"
  resource_group_name           = "${azurerm_resource_group.main_rg.name}"
  public_ip_address_allocation  = "static"
  domain_name_label             = "admin-jumpbox"

  tags {
    environment = "admin"
  }
}

// resource "azurerm_public_ip" "consul" {
//   name                         = "consul"
//   location                     = "${var.location}"
//   resource_group_name          = "${azurerm_resource_group.main_rg.name}"
//   public_ip_address_allocation = "static"
//   domain_name_label            = "consul"
//   sku                          = "Basic"

//   tags {
//     environment = "consul"
//   }
// }

#######################################################################################################################
# JumpBox

resource "azurerm_network_interface" "jumpbox_nic" {
  name                      = "jumpbox_nic"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.main_rg.name}"
  network_security_group_id = "${azurerm_network_security_group.tfjboxnsg.id}"

  ip_configuration {
    name                          = "JumboxConfig"
    subnet_id                     = "${azurerm_subnet.admin_subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.jumpbox_ip.id}"
  }

  tags {
    environment = "admin"
  }
}

resource "azurerm_virtual_machine" "jumpbox" {
  name                  = "jumpbox"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.main_rg.name}"
  network_interface_ids = ["${azurerm_network_interface.jumpbox_nic.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "jumpbox-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "datadisk_jumpbox"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "1023"
  }

  os_profile {
    computer_name  = "jumpbox"
    admin_username = "${var.jumpbox_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  connection {
    host      = "${azurerm_public_ip.jumpbox_ip.ip_address}"
    type      = "ssh"
    user      = "${var.jumpbox_username}"
    password  = "${var.admin_password}"
  }

  provisioner "remote-exec" {
    inline = [

    ]
  }

  tags {
    environment = "admin"
  }
}

// #######################################################################################################################
// # Salt Master

resource "azurerm_network_interface" "saltmaster_nic" {
  name                      = "saltmaster_nic"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.main_rg.name}"
  internal_dns_name_label   = "saltmaster"
  network_security_group_id = "${azurerm_network_security_group.serversnsg.id}"

  ip_configuration {
    name                          = "SaltMasterConfig"
    subnet_id                     = "${azurerm_subnet.admin_subnet.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.0.1.5"
  }

  tags {
    environment = "salt master"
  }
}

resource "azurerm_virtual_machine" "saltmaster" {
    name                  = "saltmaster"
    location              = "${var.location}"
    resource_group_name   = "${azurerm_resource_group.main_rg.name}"
    network_interface_ids = ["${azurerm_network_interface.saltmaster_nic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }

    storage_os_disk {
        name              = "saltmaster-osdisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_data_disk {
        name              = "datadisk_saltmaster"
        managed_disk_type = "Standard_LRS"
        create_option     = "Empty"
        lun               = 0
        disk_size_gb      = "1023"
    }

    os_profile {
        computer_name  = "saltmaster"
        admin_username = "${var.saltmaster_username}"
        admin_password = "${var.admin_password}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    connection {
      bastion_host      = "${azurerm_public_ip.jumpbox_ip.ip_address}"
      bastion_port      = "22"
      bastion_user      = "${var.jumpbox_username}"
      bastion_password  = "${var.admin_password}"

      type      = "ssh"
      user      = "${var.saltmaster_username}"
      password  = "${var.admin_password}"
      host      = "10.0.1.5"
    }

    provisioner "remote-exec" {
      inline = [
        "cd ~",
        "curl -L https://bootstrap.saltstack.com -o install_salt.sh",
        "sudo sh install_salt.sh -P -M",
        "sudo mkdir -p /srv/{salt,pillar}"
      ]
    }

    provisioner "file" {
      source  = "./saltmaster.conf"
      destination = "/tmp/saltmaster.conf"
    }

    provisioner "file" {
      source = "./saltminion.conf"
      destination = "/tmp/saltminion.conf"
    }

    provisioner "remote-exec" {
      inline = [
        "sudo mv /tmp/saltmaster.conf /etc/salt/master.d/saltmaster.conf",
        "sudo mv /tmp/saltminion.conf /etc/salt/minion.d/saltminion.conf",
        "sudo systemctl restart salt-master",
        "sudo systemctl restart salt-minion"
      ]
    }

    tags {
        environment = "salt master"
    }

    depends_on = ["azurerm_virtual_machine.jumpbox", "azurerm_network_interface.saltmaster_nic"]

}

// #######################################################################################################################
// # Load Balancer

// resource "azurerm_lb" "lb" {
//   name                = "lb"
//   location            = "${var.location}"
//   resource_group_name = "${azurerm_resource_group.main_rg.name}"
//   sku                 = "Basic"

//   frontend_ip_configuration {
//     name                 = "PublicIPAddress"
//     public_ip_address_id = "${azurerm_public_ip.lbpip.id}"
//   }
// }

// resource "azurerm_lb_backend_address_pool" "lbbackendpool" {
//   resource_group_name = "${azurerm_resource_group.main_rg.name}"
//   loadbalancer_id     = "${azurerm_lb.lb.id}"
//   name                = "BackEndAddressPool"
// }

// resource "azurerm_lb_nat_rule" "lbnatrule" {
//   count                          = "${var.vm_count}"
//   resource_group_name            = "${azurerm_resource_group.main_rg.name}"
//   loadbalancer_id                = "${azurerm_lb.lb.id}"
//   name                           = "ssh-${count.index}"
//   protocol                       = "tcp"
//   frontend_port                  = "5000${count.index + 1}"
//   backend_port                   = 22
//   frontend_ip_configuration_name = "PublicIPAddress" 
// }

// resource "azurerm_lb_rule" "lb_rule" {
//   resource_group_name            = "${azurerm_resource_group.main_rg.name}"
//   loadbalancer_id                = "${azurerm_lb.lb.id}"
//   name                           = "LBRule"
//   protocol                       = "tcp"
//   frontend_port                  = 80
//   backend_port                   = 8000
//   frontend_ip_configuration_name = "PublicIPAddress"
//   enable_floating_ip             = false
//   backend_address_pool_id        = "${azurerm_lb_backend_address_pool.lbbackendpool.id}"
//   idle_timeout_in_minutes        = 5
//   probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
//   depends_on                     = ["azurerm_lb_probe.lb_probe"]
// }

// resource "azurerm_lb_probe" "lb_probe" {
//   resource_group_name = "${azurerm_resource_group.main_rg.name}"
//   loadbalancer_id     = "${azurerm_lb.lb.id}"
//   name                = "tcpProbe"
//   protocol            = "tcp"
//   port                = 80
//   interval_in_seconds = 5
//   number_of_probes    = 2
// }


// #######################################################################################################################
// # Availability Set VMs

// resource "azurerm_availability_set" "consulavset" {
//   name                        = "consulavset"
//   location                    = "${var.location}"
//   resource_group_name         = "${azurerm_resource_group.main_rg.name}"
//   managed                     = "true"
//   platform_fault_domain_count = 2

//   tags {
//     environment = "consul"
//   }
// }


// resource "azurerm_network_interface" "consulnic" {
//   count                     = "${var.vm_count}"
//   name                      = "consul${count.index}"
//   location                  = "${var.location}"
//   resource_group_name       = "${azurerm_resource_group.main_rg.name}"
//   network_security_group_id = "${azurerm_network_security_group.frontwebnsg.id}"

//   ip_configuration {
//     name                          = "frontwebnic-config${count.index}"
//     subnet_id                     = "${azurerm_subnet.subnet1.id}"
//     #private_ip_address_allocation = "dynamic"
//     private_ip_address_allocation = "Static"
//     private_ip_address            = "${format("10.0.2.%d", count.index + 5)}"

//     load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.lbbackendpool.id}"]
//     load_balancer_inbound_nat_rules_ids = ["${azurerm_lb_nat_rule.lbnatrule.*.id[count.index]}"]
//   }

//   tags {
//     environment = "web"
//   }
// }

// resource "azurerm_virtual_machine" "consul" {
//   count                 = "${var.vm_count}"
//   name                  = "consul${count.index}"
//   location              = "${var.location}"
//   resource_group_name   = "${azurerm_resource_group.main_rg.name}"
//   network_interface_ids = ["${azurerm_network_interface.frontwebnic.*.id[count.index]}"]
//   vm_size               = "Standard_DS1_v2"
//   availability_set_id   = "${azurerm_availability_set.consulavset.id}"

//   storage_os_disk {
//     name              = "consul${count.index}-osdisk"
//     caching           = "ReadWrite"
//     create_option     = "FromImage"
//     managed_disk_type = "Standard_LRS"
//   }

//   storage_image_reference {
//     publisher = "Canonical"
//     offer     = "UbuntuServer"
//     sku       = "16.04.0-LTS"
//     version   = "latest"
//   }

//   os_profile {
//         computer_name  = "consul${count.index}"
//         admin_username = "${var.webvm_username}"
//         admin_password = "${var.admin_password}"
//     }

//   os_profile_linux_config {
//       disable_password_authentication = false
//   }

//   connection {
//       bastion_host      = "${azurerm_public_ip.jumpbox_ip.ip_address}"
//       bastion_port      = "22"
//       bastion_user      = "${var.jumpbox_username}"
//       bastion_password  = "${var.admin_password}"

//       type      = "ssh"
//       user      = "${var.webvm_username}"
//       password  = "${var.admin_password}"
//       host      = "${format("10.0.2.%d", count.index + 5)}"
//     }

//      provisioner "file" {
//       source  = "./webapp"
//       destination = "/tmp/webapp"
//     }

//     provisioner "remote-exec" {
//       inline = [
//         "cd ~",
//         "curl -L https://bootstrap.saltstack.com -o install_salt.sh",
//         "sudo sh install_salt.sh -P",
//         "chmod +x /tmp/webapp",
//         "/tmp/webapp"
//       ]
//     }

//   tags {
//     environment = "$web"
//   }

//   depends_on = ["azurerm_virtual_machine.saltmaster"]
// }