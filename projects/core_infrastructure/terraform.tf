provider "azurerm" {}

## Get core infrastructure (RG, VNet, Subnet)
module "core_infrastructure" {
    source = "../../modules/core"

    location = "${var.location}"
}