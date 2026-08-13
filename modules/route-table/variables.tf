# Variables for the Route Table module.
variable "name" {
  description = "The name of the Route Table."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Route Table."
  type        = string
}

variable "location" {
  description = "The location/region where the Route Table will be created."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the Route Table."
  type        = map(string)
  default     = {}
}

variable "route" {
  description = "A list of route objects to define the routes in the Route Table. Each route object should contain the following properties: name, address_prefix, next_hop_type, and optionally next_hop_ip_address."
  type = list(object({
    name                = string
    address_prefix      = string
    next_hop_type       = string
    next_hop_ip_address = optional(string)
  }))
}
