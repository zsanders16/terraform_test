output "resource_group_name" {
    value = "${module.core_infrastructure.resource_group_name}"
}

output "admin_subnet_id" {
    value = "${module.core_infrastructure.admin_subnet_id}"
}

// output "consul_subnet_id" {
//     value = "${module.core_infrastructure.consul_subnet_id}"
// }