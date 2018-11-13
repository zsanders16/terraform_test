provider "azurerm" {}

## Get core infrastructure (RG, VNet, Subnet)
module "core_infrastructure" {
    source = "../../modules/core"

    location = "${var.location}"
}

# Create a JumpBox
module "jump_box" {
    source = "../../modules/jumpbox"

    location = "${var.location}"
    resource_group_name = "${module.core_infrastructure.resource_group_name}"
    subnet_id = "${module.core_infrastructure.admin_subnet_id}"
}

# Create a Salt Master
module "salt_master" {
    source = "../../modules/saltmaster"

    location = "${var.location}"
    resource_group_name = "${module.core_infrastructure.resource_group_name}"
    subnet_id = "${module.core_infrastructure.admin_subnet_id}"
    jumpbox_ip_address = "${module.jump_box.jumpbox_public_ip}"
    jumpbox_username = "${module.jump_box.jumpbox_username}"
    jumpbox_password = "${module.jump_box.jumpbox_password}"
}