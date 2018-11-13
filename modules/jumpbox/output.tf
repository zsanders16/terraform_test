output "jumpbox_public_ip" {
  value = "${azurerm_public_ip.jumpbox_ip.ip_address}"
}

output "jumpbox_public_fqdn" {
  value = "${azurerm_public_ip.jumpbox_ip.fqdn}"
}

output "jumpbox_username" {
  value = "${var.jumpbox_username}"
}

output "jumpbox_password" {
  value = "${var.jumpbox_password}"
}