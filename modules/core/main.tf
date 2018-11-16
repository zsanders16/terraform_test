#####################################
# Produces:
#   - Resource Group
#   - Virtual Network
#   - Subnet
#   - NGS for both subnets if needed
#####################################


# Create a resource group
resource "azurerm_resource_group" "main_rg" {
  name     = "main_rg"
  location = "${var.location}"
}

# Create a virtual network within the resource group and subnets
resource "azurerm_virtual_network" "main_vnet" {
  name                = "main-network"
  address_space       = ["${var.vnet_address_space}"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.main_rg.name}"

}

# Create an admin subnet within the virtual network
resource "azurerm_subnet" "admin_subnet" {
  name                 = "admin_subnet"
  resource_group_name  = "${azurerm_resource_group.main_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.main_vnet.name}"
  address_prefix       = "${var.admin_subnet}"
}

resource "azurerm_subnet" "consul_subnet" {
  name                 = "consul_subnet"
  resource_group_name  = "${azurerm_resource_group.main_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.main_vnet.name}"
  address_prefix       = "${var.consul_subnet}"
}

// resource "azurerm_subnet_network_security_group_association" "admin_nsg_association" {
//   subnet_id                 = "${azurerm_subnet.admin_subnet.id}"
//   network_security_group_id = "${azurerm_network_security_group.admin.id}"
// }

// resource "azurerm_subnet_network_security_group_association" "consul_nsg_association" {
//   subnet_id                 = "${azurerm_subnet.consul_subnet.id}"
//   network_security_group_id = "${azurerm_network_security_group.consul.id}"
// }

# ---------------------------------------------------------------------------------------------------------------------
# NSG FOR SUBNET ADMIN_SUBNET
# ---------------------------------------------------------------------------------------------------------------------

// resource "azurerm_network_security_group" "admin" {
//   name = "consul_servers"
//   location = "${var.location}"
//   resource_group_name = "${var.resource_group_name}"
// }

# ---------------------------------------------------------------------------------------------------------------------
# NSG FOR SUBNET CONSUL_SUBNET
# ---------------------------------------------------------------------------------------------------------------------

// resource "azurerm_network_security_group" "consul" {
//   name = "consul_servers"
//   location = "${var.location}"
//   resource_group_name = "${var.resource_group_name}"
// }

// resource "azurerm_network_security_rule" "allow_server_rpc_inbound" {
//   count = "${length(var.allowed_inbound_cidr_blocks)}"

//   access = "Allow"
//   destination_address_prefix = "*"
//   destination_port_range = "${var.server_rpc_port}"
//   direction = "Inbound"
//   name = "ServerRPC${count.index}"
//   network_security_group_name = "${azurerm_network_security_group.consul.name}"
//   priority = "${200 + count.index}"
//   protocol = "Tcp"
//   resource_group_name = "${var.resource_group_name}"
//   source_address_prefix = "${element(var.allowed_inbound_cidr_blocks, count.index)}"
//   source_port_range = "1024-65535"
// }

// resource "azurerm_network_security_rule" "allow_cli_rpc_inbound" {
//   count = "${length(var.allowed_inbound_cidr_blocks)}"

//   access = "Allow"
//   destination_address_prefix = "*"
//   destination_port_range = "${var.cli_rpc_port}"
//   direction = "Inbound"
//   name = "CLIRPC${count.index}"
//   network_security_group_name = "${azurerm_network_security_group.consul.name}"
//   priority = "${250 + count.index}"
//   protocol = "Tcp"
//   resource_group_name = "${var.resource_group_name}"
//   source_address_prefix = "${element(var.allowed_inbound_cidr_blocks, count.index)}"
//   source_port_range = "1024-65535"
// }

// resource "azurerm_network_security_rule" "allow_serf_lan_tcp_inbound" {
//   count = "${length(var.allowed_inbound_cidr_blocks)}"

//   access = "Allow"
//   destination_address_prefix = "*"
//   destination_port_range = "${var.serf_lan_port}"
//   direction = "Inbound"
//   name = "SerfLan${count.index}"
//   network_security_group_name = "${azurerm_network_security_group.consul.name}"
//   priority = "${300 + count.index}"
//   protocol = "Tcp"
//   resource_group_name = "${var.resource_group_name}"
//   source_address_prefix = "${element(var.allowed_inbound_cidr_blocks, count.index)}"
//   source_port_range = "1024-65535"
// }

// resource "azurerm_network_security_rule" "allow_serf_lan_udp_inbound" {
//   count = "${length(var.allowed_inbound_cidr_blocks)}"

//   access = "Allow"
//   destination_address_prefix = "*"
//   destination_port_range = "${var.serf_lan_port}"
//   direction = "Inbound"
//   name = "SerfLanUdp${count.index}"
//   network_security_group_name = "${azurerm_network_security_group.consul.name}"
//   priority = "${350 + count.index}"
//   protocol = "Udp"
//   resource_group_name = "${var.resource_group_name}"
//   source_address_prefix = "${element(var.allowed_inbound_cidr_blocks, count.index)}"
//   source_port_range = "1024-65535"
// }

// resource "azurerm_network_security_rule" "allow_serf_wan_tcp_inbound" {
//   count = "${length(var.allowed_inbound_cidr_blocks)}"

//   access = "Allow"
//   destination_address_prefix = "*"
//   destination_port_range = "${var.serf_wan_port}"
//   direction = "Inbound"
//   name = "SerfWan${count.index}"
//   network_security_group_name = "${azurerm_network_security_group.consul.name}"
//   priority = "${400 + count.index}"
//   protocol = "Tcp"
//   resource_group_name = "${var.resource_group_name}"
//   source_address_prefix = "${element(var.allowed_inbound_cidr_blocks, count.index)}"
//   source_port_range = "1024-65535"
// }

// resource "azurerm_network_security_rule" "allow_serf_wan_udp_inbound" {
//   count = "${length(var.allowed_inbound_cidr_blocks)}"

//   access = "Allow"
//   destination_address_prefix = "*"
//   destination_port_range = "${var.serf_wan_port}"
//   direction = "Inbound"
//   name = "SerfWanUdp${count.index}"
//   network_security_group_name = "${azurerm_network_security_group.consul.name}"
//   priority = "${450 + count.index}"
//   protocol = "Udp"
//   resource_group_name = "${var.resource_group_name}"
//   source_address_prefix = "${element(var.allowed_inbound_cidr_blocks, count.index)}"
//   source_port_range = "1024-65535"
// }

// resource "azurerm_network_security_rule" "allow_http_api_inbound" {
//   count = "${length(var.allowed_inbound_cidr_blocks)}"

//   access = "Allow"
//   destination_address_prefix = "*"
//   destination_port_range = "${var.http_api_port}"
//   direction = "Inbound"
//   name = "HttpApi${count.index}"
//   network_security_group_name = "${azurerm_network_security_group.consul.name}"
//   priority = "${500 + count.index}"
//   protocol = "Tcp"
//   resource_group_name = "${var.resource_group_name}"
//   source_address_prefix = "${element(var.allowed_inbound_cidr_blocks, count.index)}"
//   source_port_range = "1024-65535"
// }

// resource "azurerm_network_security_rule" "allow_dns_tcp_inbound" {
//   count = "${length(var.allowed_inbound_cidr_blocks)}"

//   access = "Allow"
//   destination_address_prefix = "*"
//   destination_port_range = "${var.dns_port}"
//   direction = "Inbound"
//   name = "Dns${count.index}"
//   network_security_group_name = "${azurerm_network_security_group.consul.name}"
//   priority = "${550 + count.index}"
//   protocol = "Tcp"
//   resource_group_name = "${var.resource_group_name}"
//   source_address_prefix = "${element(var.allowed_inbound_cidr_blocks, count.index)}"
//   source_port_range = "1024-65535"
// }

// resource "azurerm_network_security_rule" "allow_dns_udp_inbound" {
//   count = "${length(var.allowed_inbound_cidr_blocks)}"

//   access = "Allow"
//   destination_address_prefix = "*"
//   destination_port_range = "${var.dns_port}"
//   direction = "Inbound"
//   name = "Dns${count.index}"
//   network_security_group_name = "${azurerm_network_security_group.consul.name}"
//   priority = "${600 + count.index}"
//   protocol = "Udp"
//   resource_group_name = "${var.resource_group_name}"
//   source_address_prefix = "${element(var.allowed_inbound_cidr_blocks, count.index)}"
//   source_port_range = "1024-65535"
// }