######################################
#             MODULE INPUT
#
#               REQUIRED
#
# location = ""
# resource_group_name = ""
# subnet_id = ""
# count = ""
# image_id = ""
# custom_extension = ""
#
#               OPTIONAL
#
######################################

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "location" {
  description = "The location that the resources will run in (e.g. East US)"
}

variable "resource_group_name" {
  description = "The name of the resource group that the resources for consul will run in"
}

variable "subnet_id" {
  description = "The id of the subnet to deploy the cluster into"
}

variable "count" {
  description = "Number of servers in the Scale Set"
}

variable "image_id" {
  description = "The URI to the Azure image that should be deployed to the consul cluster."
}

variable "custom_extension" {
  description = "extensions to run after build"
  type = "map"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

