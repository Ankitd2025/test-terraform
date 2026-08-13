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
