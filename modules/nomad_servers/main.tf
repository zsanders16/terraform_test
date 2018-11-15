resource "azurerm_network_interface" "nomad_server" {
    count               = "${var.count}"
    name                = "nomad_server"
    location            = "${var.location}"
    resource_group_name = "${var.resource_group_name}"

    ip_configuration {
        name                          = "nomad_server_config"
        subnet_id                     = "${var.subnet_id}"
        private_ip_address_allocation = "static"
        private_ip_address            = "10.0.1.1${count.index}"
    }
}

resource "azurerm_virtual_machine" "main" {
    count                 = "${var.count}"
    name                  = "nomad_server${count.index}"
    location              = "${var.location}"
    resource_group_name   = "${var.resource_group_name}"
    network_interface_ids = ["${element(azurerm_network_interface.nomad_server.*.id)}"]
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
        name              = "nomad_server${count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    os_profile {
        computer_name  = "nomad_server${count.index}"
        admin_username = "nomadadmin"
        admin_password = "Password1234!"
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
        user      = "nomadadmin"
        password  = "Password1234!"
        host      = "${element(azurerm_network_interface.nomad_server.*.id)}"
    }

    provisioner "remote-exec" {
        inline = [
        "cd ~",
        "curl -L https://bootstrap.saltstack.com -o install_salt.sh",
        "sudo sh install_salt.sh -P"
        ]
    }

    provisioner "file" {
        source = "../../files/saltstack/saltminion.conf"
        destination = "/tmp/saltminion.conf"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo mv /tmp/saltminion.conf /etc/salt/minion.d/saltminion.conf",
            "sudo echo 'id: nomad_server${count.index}' >> /etc/salt/minion.d/saltminion.conf",
            "sudo systemctl restart salt-minion"
        ]
    }
    tags {
        environment = "nomad"
    }
}