# Variables for the Private DNS Zone module
variable "name" {
  description = "The name of the Private DNS Zone."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Private DNS Zone."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
}

variable "location" {
  description = "The Azure region where the Private DNS Zone will be created."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "A list of Private DNS Zone IDs to link with the Private Endpoint."
  type        = list(string)
}

variable "private_connection_resource_id" {
  description = "The ID of the resource to which the Private Endpoint will connect."
  type        = string
}

variable "subresource_names" {
  description = "A list of subresource names for the Private Endpoint connection."
  type        = list(string)
}

variable "subnet_id" {
  description = "The ID of the Subnet Resource"
  type        = string
}

