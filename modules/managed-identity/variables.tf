# Variables for the Managed Identity module
variable "name" {
  description = "The name of the Managed Identity."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the Managed Identity will be created."
  type        = string
}

variable "location" {
  description = "The Azure region where the Managed Identity will be created."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the Managed Identity."
  type        = map(string)
  default     = {}
}