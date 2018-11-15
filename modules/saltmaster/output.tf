output "salt_ip" {
    value = "${azurerm_network_interface.saltmaster_nic.private_ip_address}"
}