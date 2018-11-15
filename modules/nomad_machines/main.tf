resource "azurerm_network_interface" "nomad" {
    name                = "${var.prefix}-nic"
    location            = "${var.location}"
    resource_group_name = "${var.resource_group_name}"

    ip_configuration {
        name                          = "nomadConfig"
        subnet_id                     = "${var.subnet_id}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_virtual_machine" "main" {
    count                 = 3
    name                  = "nomad-vm${count.index}"
    location              = "${var.location}"
    resource_group_name   = "${var.resource_group_name}"
    network_interface_ids = ["${azurerm_network_interface.nomad.id}"]
    vm_size               = "Standard_DS1_v2"

    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
    }
    storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    }
    os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
    }
    os_profile_linux_config {
    disable_password_authentication = false
    }
    tags {
    environment = "nomad"
    }
}