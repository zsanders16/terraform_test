output "resource_group_name" {
    value = "${azurerm_resource_group.main_rg.name}"
}

output "admin_subnet_id" {
    value = "${azurerm_subnet.admin_subnet.id}"
}

// output "consul_subnet_id" {
//     value = "${azurerm_subnet.consul_subnet.id}"
// }