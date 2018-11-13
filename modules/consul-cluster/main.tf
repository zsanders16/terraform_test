##################################
# Produces:
#   - scale set
##################################

resource "azurerm_virtual_machine_scale_set" "cosul" {
  name                = "consul_scale_set"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  upgrade_policy_mode  = "Automatic"

  sku {
    name     = "Standard_F2"
    tier     = "Standard"
    capacity = "${var.count}"
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "consulvm"
    admin_username       = "consuladmin"
    admin_password       = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    // ssh_keys {
    //   path     = "/home/myadmin/.ssh/authorized_keys"
    //   key_data = "${file("~/.ssh/demo_key.pub")}"
    // }
  }

  network_profile {
    name    = "consulnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "consul_ip_config"
      primary                                = true
      subnet_id                              = "${var.subnet_id}"
    }
  }

  tags {
    environment = "admin"
  }
}

