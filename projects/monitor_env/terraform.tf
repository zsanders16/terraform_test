provider "azurerm" {
    // tenant_id = "e49ad2a1-4515-48a6-935a-d2f61819b5cb"
    // client_id = "32846ccf-c090-4dd1-bb99-f1ab8cc91d6f"
    // client_secret = "48d0d6a2-9755-430e-89e3-879440d37c93"
    // tenant_id = "e49ad2a1-4515-48a6-935a-d2f61819b5cb"
}

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

# Create a Consul Server Cluster
module "consul_servers" {
    source = "../../modules/consul_servers"

    location = "${var.location}"
    resource_group_name = "${module.core_infrastructure.resource_group_name}"
    subnet_id = "${module.core_infrastructure.admin_subnet_id}"
    count = "3"
    image_id = "${var.image_id}"
}