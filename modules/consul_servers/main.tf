###############################################################
# Produces:
#   - scale set
#   - Network Security Group
#   - Adds multiple security rules to the given security group
###############################################################

# ---------------------------------------------------------------------------------------------------------------------
# NSG
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_network_security_group" "consul" {
  name = "consul_servers"
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_security_rule" "allow_server_rpc_inbound" {
  count = "${length(var.allowed_inbound_cidr_blocks)}"

  access = "Allow"
  destination_address_prefix = "*"
  destination_port_range = "${var.server_rpc_port}"
  direction = "Inbound"
  name = "ServerRPC${count.index}"
  network_security_group_name = "${azurerm_network_security_group.consul.name}"
  priority = "${200 + count.index}"
  protocol = "Tcp"
  resource_group_name = "${var.resource_group_name}"
  source_address_prefix = "${element(var.allowed_inbound_cidr_blocks, count.index)}"
  source_port_range = "1024-65535"
}

resource "azurerm_network_security_rule" "allow_cli_rpc_inbound" {
  count = "${length(var.allowed_inbound_cidr_blocks)}"

  access = "Allow"
  destination_address_prefix = "*"
  destination_port_range = "${var.cli_rpc_port}"
  direction = "Inbound"
  name = "CLIRPC${count.index}"
  network_security_group_name = "${azurerm_network_security_group.consul.name}"
  priority = "${250 + count.index}"
  protocol = "Tcp"
  resource_group_name = "${var.resource_group_name}"
  source_address_prefix = "${element(var.allowed_inbound_cidr_blocks, count.index)}"
  source_port_range = "1024-65535"
}

resource "azurerm_network_security_rule" "allow_serf_lan_tcp_inbound" {
  count = "${length(var.allowed_inbound_cidr_blocks)}"

  access = "Allow"
  destination_address_prefix = "*"
  destination_port_range = "${var.serf_lan_port}"
  direction = "Inbound"
  name = "SerfLan${count.index}"
  network_security_group_name = "${azurerm_network_security_group.consul.name}"
  priority = "${300 + count.index}"
  protocol = "Tcp"
  resource_group_name = "${var.resource_group_name}"
  source_address_prefix = "${element(var.allowed_inbound_cidr_blocks, count.index)}"
  source_port_range = "1024-65535"
}

resource "azurerm_network_security_rule" "allow_serf_lan_udp_inbound" {
  count = "${length(var.allowed_inbound_cidr_blocks)}"

  access = "Allow"
  destination_address_prefix = "*"
  destination_port_range = "${var.serf_lan_port}"
  direction = "Inbound"
  name = "SerfLanUdp${count.index}"
  network_security_group_name = "${azurerm_network_security_group.consul.name}"
  priority = "${350 + count.index}"
  protocol = "Udp"
  resource_group_name = "${var.resource_group_name}"
  source_address_prefix = "${element(var.allowed_inbound_cidr_blocks, count.index)}"
  source_port_range = "1024-65535"
}

resource "azurerm_network_security_rule" "allow_serf_wan_tcp_inbound" {
  count = "${length(var.allowed_inbound_cidr_blocks)}"

  access = "Allow"
  destination_address_prefix = "*"
  destination_port_range = "${var.serf_wan_port}"
  direction = "Inbound"
  name = "SerfWan${count.index}"
  network_security_group_name = "${azurerm_network_security_group.consul.name}"
  priority = "${400 + count.index}"
  protocol = "Tcp"
  resource_group_name = "${var.resource_group_name}"
  source_address_prefix = "${element(var.allowed_inbound_cidr_blocks, count.index)}"
  source_port_range = "1024-65535"
}

resource "azurerm_network_security_rule" "allow_serf_wan_udp_inbound" {
  count = "${length(var.allowed_inbound_cidr_blocks)}"

  access = "Allow"
  destination_address_prefix = "*"
  destination_port_range = "${var.serf_wan_port}"
  direction = "Inbound"
  name = "SerfWanUdp${count.index}"
  network_security_group_name = "${azurerm_network_security_group.consul.name}"
  priority = "${450 + count.index}"
  protocol = "Udp"
  resource_group_name = "${var.resource_group_name}"
  source_address_prefix = "${element(var.allowed_inbound_cidr_blocks, count.index)}"
  source_port_range = "1024-65535"
}

resource "azurerm_network_security_rule" "allow_http_api_inbound" {
  count = "${length(var.allowed_inbound_cidr_blocks)}"

  access = "Allow"
  destination_address_prefix = "*"
  destination_port_range = "${var.http_api_port}"
  direction = "Inbound"
  name = "HttpApi${count.index}"
  network_security_group_name = "${azurerm_network_security_group.consul.name}"
  priority = "${500 + count.index}"
  protocol = "Tcp"
  resource_group_name = "${var.resource_group_name}"
  source_address_prefix = "${element(var.allowed_inbound_cidr_blocks, count.index)}"
  source_port_range = "1024-65535"
}

resource "azurerm_network_security_rule" "allow_dns_tcp_inbound" {
  count = "${length(var.allowed_inbound_cidr_blocks)}"

  access = "Allow"
  destination_address_prefix = "*"
  destination_port_range = "${var.dns_port}"
  direction = "Inbound"
  name = "Dns${count.index}"
  network_security_group_name = "${azurerm_network_security_group.consul.name}"
  priority = "${550 + count.index}"
  protocol = "Tcp"
  resource_group_name = "${var.resource_group_name}"
  source_address_prefix = "${element(var.allowed_inbound_cidr_blocks, count.index)}"
  source_port_range = "1024-65535"
}

resource "azurerm_network_security_rule" "allow_dns_udp_inbound" {
  count = "${length(var.allowed_inbound_cidr_blocks)}"

  access = "Allow"
  destination_address_prefix = "*"
  destination_port_range = "${var.dns_port}"
  direction = "Inbound"
  name = "Dns${count.index}"
  network_security_group_name = "${azurerm_network_security_group.consul.name}"
  priority = "${600 + count.index}"
  protocol = "Udp"
  resource_group_name = "${var.resource_group_name}"
  source_address_prefix = "${element(var.allowed_inbound_cidr_blocks, count.index)}"
  source_port_range = "1024-65535"
}


# ---------------------------------------------------------------------------------------------------------------------
# Scale Set
# ---------------------------------------------------------------------------------------------------------------------


resource "azurerm_virtual_machine_scale_set" "consul" {
  name                = "consul_scale_set"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  upgrade_policy_mode  = "Automatic"

  sku {
    name     = "Standard_F2s_v2"
    tier     = "Standard"
    capacity = "${var.count}"
  }

  storage_profile_image_reference {
    id = "${var.image_id}"
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
    network_security_group_id = "${azurerm_network_security_group.consul.id}"

    ip_configuration {
      name      = "consul_ip_config"
      primary   = true
      subnet_id = "${var.subnet_id}"
    }
  }

  extension = "${list(var.custom_extension)}"

  tags {
    environment = "admin"
  }
}