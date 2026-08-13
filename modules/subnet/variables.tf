# Variables for Azure Subnet module
variable "name" {
  description = "The name of the subnet."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the subnet."
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the virtual network in which to create the subnet."
  type        = string
}

variable "address_prefixes" {
  description = "The address prefixes to use for the subnet."
  type        = list(string)
}

variable "service_endpoints" {
  description = "A list of service endpoints to enable for the subnet."
  type        = list(string)
  default     = []
}

variable "private_endpoint_network_policies" {
  description = "Whether to disable private endpoint network policies for the subnet."
  type        = string
}

variable "delegation_name" {
  description = "The name of the delegation to apply to the subnet."
  type        = string
  default     = null
}

variable "delegation_service_name" {
  description = "The name of the service to which the subnet will be delegated."
  type        = string
  default     = null
}

variable "delegation_actions" {
  description = "A list of actions to allow for the delegation."
  type        = list(string)
  default     = []
}

variable "location" {
  description = "The location/region where the subnet will be created."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the subnet."
  type        = map(string)
  default     = {}
}

