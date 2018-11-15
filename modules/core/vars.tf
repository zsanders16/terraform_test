######################################
#            MODULE INPUT
#
#              Required
# location = ""
#
#              Optional
# vnet_address_space = ""
# admin_subnet = ""
######################################

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "location" {
    description = "location"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "vnet_address_space" {
  description = "vnet address space"
  default     = "10.0.0.0/16"
}

variable "admin_subnet" {
  description = "admin subnet"
  default     = "10.0.1.0/24"
}

variable "consul_subnet" {
  description = "consul subnet"
  default     = "10.0.2.0/24"
}