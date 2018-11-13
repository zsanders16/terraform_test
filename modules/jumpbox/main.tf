##################################
# Produces:
#   - Jumpbox Server w/ NIC
#   - Public IP
#   - Network Security Group
#
# Jumpbox must be created before any 
# other server that you want to configure
# through the Jumpbox.
##################################

## Create a Network security group for the jumpbox
resource "azurerm_network_security_group" "tfjboxnsg" {
  name                = "jumpboxnsg"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

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


## Create a public IP for the jumpbox
resource "azurerm_public_ip" "jumpbox_ip" {
  name                          = "jumpbox_public_ip"
  location                      = "${var.location}"
  resource_group_name           = "${var.resource_group_name}"
  public_ip_address_allocation  = "static"
  domain_name_label             = "admin-jumpbox"

  tags {
    environment = "admin"
  }
}

##  Create the Jumpbox NIC
resource "azurerm_network_interface" "jumpbox_nic" {
  name                      = "jumpbox_nic"
  location                  = "${var.location}"
  resource_group_name       = "${var.resource_group_name}"
  network_security_group_id = "${azurerm_network_security_group.tfjboxnsg.id}"

  ip_configuration {
    name                          = "JumboxConfig"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.jumpbox_ip.id}"
  }

  tags {
    environment = "admin"
  }
}

## Create the Jumpbox Virtual Machine
resource "azurerm_virtual_machine" "jumpbox" {
  name                  = "jumpbox"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
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
    admin_password = "${var.jumpbox_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  connection {
    host      = "${azurerm_public_ip.jumpbox_ip.ip_address}"
    type      = "ssh"
    user      = "${var.jumpbox_username}"
    password  = "${var.jumpbox_password}"
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
      "sudo echo 'id: jumpbox' >> /etc/salt/minion.d/saltminion.conf",
      "sudo systemctl restart salt-minion"
    ]
  }

  tags {
    environment = "admin"
  }
}