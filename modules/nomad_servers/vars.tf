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
# count = ""
# description = ""
# default = ""
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

variable "jumpbox_ip_address" {
    description = "jumpbox ip address in order to configure SaltMaster"
}

variable "jumpbox_username" {
    description = "jumpbox username in order to configure SaltMaster"
}

variable "jumpbox_password" {
    description = "Jumpbox password in order to configure SaltMaster"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "count" {
    description = "Total number of Nomad Servers"
    default = 3
}

variable "nomad_username" {
    description = "Nomad username"
    default = "nomadadmin"
}

variable "nomad_password" {
    description = "Nomad password"
    default = "Password1234!"
}
