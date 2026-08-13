# Variables for the Azure Resource Group
variable "name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The location of the resource group."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource group."
  type        = map(string)
}
