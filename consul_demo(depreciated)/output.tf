output "jumpbox_public_ip" {
  value = "${azurerm_public_ip.jumpbox_ip.ip_address}"
}

output "jumpbox_public_fqdn" {
  value = "${azurerm_public_ip.jumpbox_ip.fqdn}"
}

output "saltmaster_ip" {
  value = "${azurerm_network_interface.saltmaster_nic.private_ip_address}"
}

output "saltmaster_internal_fqdn" {
  value = "${azurerm_network_interface.saltmaster_nic.internal_fqdn}"
}

// output "lb_pip" {
//   value = "${azurerm_public_ip.lbpip.*.ip_address}"
// }