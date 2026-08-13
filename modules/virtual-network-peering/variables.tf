# Variables for virtual network peering module
variable "name" {
  description = "The name of the virtual network peering."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the virtual network peering is created."
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the virtual network in which the peering is created."
  type        = string
}

variable "remote_virtual_network_id" {
  description = "The ID of the remote virtual network to peer with."
  type        = string
}

variable "allow_virtual_network_access" {
  description = "Whether to allow virtual network access between the peered virtual networks."
  type        = bool
}

variable "allow_forwarded_traffic" {
  description = "Whether to allow forwarded traffic from the peered virtual network."
  type        = bool
}

variable "allow_gateway_transit" {
  description = "Whether to allow gateway transit between the peered virtual networks."
  type        = bool
}

variable "use_remote_gateways" {
  description = "Whether to use remote gateways for the peered virtual network."
  type        = bool
}