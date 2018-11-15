output "nomad_ips" {
    value = "${azurerm_network_interface.nomad_server.*.id}"
}