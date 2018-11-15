provider "azurerm" {}

# Create a JumpBox
module "jump_box" {
    source = "../../modules/jumpbox"

    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    subnet_id = "${var.admin_subnet_id}"
}

# Create a Salt Master
module "salt_master" {
    source = "../../modules/saltmaster"

    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    subnet_id = "${var.admin_subnet_id}"
    jumpbox_ip_address = "${module.jump_box.jumpbox_public_ip}"
    jumpbox_username = "${module.jump_box.jumpbox_username}"
    jumpbox_password = "${module.jump_box.jumpbox_password}"
}

# Create a Consul Server Cluster
module "consul_servers" {
    source = "../../modules/consul_servers"

    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    subnet_id = "${var.admin_subnet_id}"
    count = "3"
    image_id = "${var.image_id}"
    salt_ip = "${module.salt_master.salt_ip}"
    custom_extension          = {
        name                    = "customScript"
        publisher               = "Microsoft.Azure.Extensions"
        type                    = "CustomScript"
        type_handler_version    = "2.0"
        settings                = <<SETTINGS
            {
            "commandToExecute": "echo \"$(hostname -s).insights.consul.dev\" | sudo tee /etc/salt/minion_id > /dev/null"
            }
        SETTINGS
    }
}