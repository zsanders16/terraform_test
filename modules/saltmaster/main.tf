##################################
# Produces:
#   - SaltMaster Server w/ NIC
#   - Network Security Group
##################################

resource "azurerm_network_security_group" "saltnsg" {
  name                = "ssaltnsg"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

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

resource "azurerm_network_interface" "saltmaster_nic" {
  name                      = "saltmaster_nic"
  location                  = "${var.location}"
  resource_group_name       = "${var.resource_group_name}"
  internal_dns_name_label   = "saltmaster"
  network_security_group_id = "${azurerm_network_security_group.saltnsg.id}"

  ip_configuration {
    name                          = "SaltMasterConfig"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.salt_ip_address}"
  }

  tags {
    environment = "salt master"
  }
}

resource "azurerm_virtual_machine" "saltmaster" {
    name                  = "saltmaster"
    location              = "${var.location}"
    resource_group_name   = "${var.resource_group_name}"
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
        admin_password = "${var.salt_password}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    connection {
      bastion_host      = "${var.jumpbox_ip_address}"
      bastion_port      = "22"
      bastion_user      = "${var.jumpbox_username}"
      bastion_password  = "${var.jumpbox_password}"

      type      = "ssh"
      user      = "${var.saltmaster_username}"
      password  = "${var.salt_password}"
      host      = "${var.salt_ip_address}"
    }

    provisioner "remote-exec" {
      inline = [
        "cd ~",
        "curl -L https://bootstrap.saltstack.com -o install_salt.sh",
        "sudo sh install_salt.sh -P -M"
      ]
    }

    provisioner "file" {
      source  = "../../files/saltstack/saltmaster.conf"
      destination = "/tmp/saltmaster.conf"
    }

    provisioner "file" {
      source = "../../files/saltstack/saltminion.conf"
      destination = "/tmp/saltminion.conf"
    }

    provisioner "file" {
      source  = "../../files/saltstack/salt"
      destination = "/tmp"
    }

    provisioner "file" {
      source  = "../../files/saltstack/_modules"
      destination = "/tmp"
    }

    provisioner "remote-exec" {
      inline = [
        "sudo mv /tmp/saltmaster.conf /etc/salt/master.d/saltmaster.conf",
        "sudo mv /tmp/saltminion.conf /etc/salt/minion.d/saltminion.conf",
        "sudo mv /tmp/salt /srv/",
        "sudo mv /tmp/_modules /srv/salt/",
        "sudo echo 'id: master' >> /etc/salt/minion.d/saltminion.conf",
        "sudo systemctl restart salt-master",
        "sudo systemctl restart salt-minion"
      ]
    }

    tags {
        environment = "salt master"
    }

}