######################################
#            MODULE INPUT
#
#              Required
# location = ""
#
#              Optional
# vnet_address_space = ""
# admin_subnet = ""
# allowed_inbound_cidr_blocks = ""
# server_rpc_port = ""
# cli_rpc_port = ""
# serf_lan_port = ""
# serf_wan_port = ""
# http_api_port = ""
# dns_port = ""
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

// variable "allowed_inbound_cidr_blocks" {
//   description = "A list of CIDR-formatted IP address ranges from which the Azure Instances will allow connections to Consul"
//   type        = "list"
//   default = ["10.0.1.0/24", "10.0.2.0/24"]
// }
 
// variable "server_rpc_port" {
//   description = "The port used by servers to handle incoming requests from other agents."
//   default     = 8300
// }

// variable "cli_rpc_port" {
//   description = "The port used by all agents to handle RPC from the CLI."
//   default     = 8400
// }

// variable "serf_lan_port" {
//   description = "The port used to handle gossip in the LAN. Required by all agents."
//   default     = 8301
// }

// variable "serf_wan_port" {
//   description = "The port used by servers to gossip over the WAN to other servers."
//   default     = 8302
// }

// variable "http_api_port" {
//   description = "The port used by clients to talk to the HTTP API"
//   default     = 8500
// }

// variable "dns_port" {
//   description = "The port used to resolve DNS queries."
//   default     = 8600
// }