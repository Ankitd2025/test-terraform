# Variables for the Azure User Assigned Managed Identity module
variable "name" {
  description = "The name of the user-assigned managed identity."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the user-assigned managed identity."
  type        = string
}

variable "location" {
  description = "The Azure region where the user-assigned managed identity will be created."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the user-assigned managed identity."
  type        = map(string)
  default     = {}
}
