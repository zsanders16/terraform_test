######################################
#             MODULE INPUT
#
#               REQUIRED 
# location = ""
# resource_group_name = ""
# subnet_id = ""
# count = ""
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

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
