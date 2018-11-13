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
      "cd ~",
      "curl -L https://bootstrap.saltstack.com -o install_salt.sh",
      "sudo sh install_salt.sh -P"
    ]
  }

  provisioner "file" {
    source = "./saltminionjump.conf"
    destination = "/tmp/saltminion.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/saltminion.conf /etc/salt/minion.d/saltminion.conf",
      "sudo systemctl restart salt-minion"
    ]
  }

  tags {
    environment = "admin"
  }
}


// #######################################################################################################################
// # Consul Servers

module "consul_cluster" {
  source = "../modules/consul-cluster"

  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.main_rg.name}"
  subnet_id = "${azurerm_subnet.admin_subnet.id}"

}