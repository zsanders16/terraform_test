output "jump_box_public_ip" {
    value = "${module.jump_box.jumpbox_public_ip}"
}

output "jump_box_public_fqdn" {
    value = "${module.jump_box.jumpbox_public_fqdn}"
}
