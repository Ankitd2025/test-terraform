# Variables for the Azure Public IP Address

variable "name" {
  description = "The name of the public IP address."
  type        = string
}

variable "location" {
  description = "The location of the public IP address."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the public IP address."
  type        = string
}

variable "allocation_method" {
  description = "The allocation method of the public IP address."
  type        = string
}

variable "sku" {
  description = "The SKU of the public IP address."
  type        = string
}

variable "zones" {
  description = "The availability zones of the public IP address."
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to assign to the public IP address."
  type        = map(string)
}

variable "ddos_protection_mode" {
  description = "The DDoS protection mode of the public IP address."
  type        = string
}

