##################################
# Produces:
#   - Resource Group
#   - Virtual Network
#   - Subnet
##################################


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

// resource "azurerm_subnet" "consul_subnet" {
//   name                 = "consul_subnet"
//   resource_group_name  = "${azurerm_resource_group.main_rg.name}"
//   virtual_network_name = "${azurerm_virtual_network.main_vnet.name}"
//   address_prefix       = "${var.consul_subnet}"
// }