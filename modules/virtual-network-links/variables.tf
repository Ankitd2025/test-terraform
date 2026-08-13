# Variables for the Private DNS Zone virtual network link module
variable "name" {
  description = "The name of the Private DNS Zone virtual network link."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Private DNS Zone virtual network link."
  type        = string
}

variable "private_dns_zone_name" {
  description = "The name of the Private DNS Zone to which the virtual network will be linked."
  type        = string
}

variable "virtual_network_id" {
  description = "The ID of the virtual network to link with the Private DNS Zone."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the Private DNS Zone virtual network link."
  type        = map(string)
}