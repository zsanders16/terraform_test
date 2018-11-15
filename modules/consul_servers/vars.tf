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

variable "salt_ip" {
  description = "not used"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "allowed_inbound_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the Azure Instances will allow connections to Consul"
  type        = "list"
  default = ["10.0.1.0/24"]
}
 
variable "server_rpc_port" {
  description = "The port used by servers to handle incoming requests from other agents."
  default     = 8300
}

variable "cli_rpc_port" {
  description = "The port used by all agents to handle RPC from the CLI."
  default     = 8400
}

variable "serf_lan_port" {
  description = "The port used to handle gossip in the LAN. Required by all agents."
  default     = 8301
}

variable "serf_wan_port" {
  description = "The port used by servers to gossip over the WAN to other servers."
  default     = 8302
}

variable "http_api_port" {
  description = "The port used by clients to talk to the HTTP API"
  default     = 8500
}

variable "dns_port" {
  description = "The port used to resolve DNS queries."
  default     = 8600
}