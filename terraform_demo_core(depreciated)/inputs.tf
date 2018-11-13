variable "location" {
  description = "azure region"
  default     = "West US 2"
}

variable "vnet_address_space" {
  description = "vnet address space"
  default     = "10.0.0.0/16"
}

variable "admin_subnet" {
  description = "admin subnet"
  default     = "10.0.1.0/24"
}

variable "subnet1" {
  description = "subnet1"
  default     = "10.0.2.0/24"
}

variable "admin_password" {
  description = "Admin Password"
  default     = "Password1234!"
}

variable "jumpbox_username" {
  description = "Jumpbox username"
  default = "jumpboxuser"
}

variable "saltmaster_username" {
  description = "Salt Master username"
  default = "saltmasteruser"
}

variable "consul_username" {
  description = " Web VMs username"
  default = "consuluser"
}

variable "vm_count" {
  description = "Number of VMs to create"
  default = 2
}


//////////////////////////////////
///////  Consul Specific  ////////
//////////////////////////////////

variable "allowed_inbound_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the Azure Instances will allow connections to Consul"
  type        = "list"
}


          ///////////////////////////
          ///       Optional      ///
          ///////////////////////////
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