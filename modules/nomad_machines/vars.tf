######################################
#           MODULE INPUT
#
#             REQUIRED
# location = ""
# resource_group_name = ""
# subnet_id = ""
# jumpbox_ip_address = ""
# jumpbox_username = ""
# jumpbox_password = ""
#
#             OPTIONAL
# jumpbox_username = ""
# jumpbox_password = ""
######################################

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "location" {
  description = "azure region"
}

variable "resource_group_name" {
  description = "The name of the resource group that the resources for consul will run in"
}

variable "subnet_id" {
  description = "The id of the subnet to deploy the cluster into"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "jumpbox_username" {
    description = "Username for the jumpbox"
    default = "jumpboxuser"
}

variable "jumpbox_password" {
    description = "Password for the jumpbox"
    default = "Password1234!"
}