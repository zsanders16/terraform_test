variable "location" {
    description = "Azure region"
}

variable "image_id" {
    description = "The URI to the Azure image that should be deployed to the consul cluster."
}

variable "resource_group_name" {
    description = "name of the resource group in which you will be building"
}

variable "admin_subnet_id" {
    description = "id of the admin subnet in which you will be building"
}

// variable "consul_subnet_id" {
//     description = "id of the consul subnet in which you will be building"
// }
