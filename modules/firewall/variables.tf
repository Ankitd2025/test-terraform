# Variables for Azure Firewall module
variable "name" {
  description = "The name of the Azure Firewall."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Azure Firewall."
  type        = string
}

variable "location" {
  description = "The location/region where the Azure Firewall will be created."
  type        = string
}

variable "sku_name" {
  description = "The SKU name for the Azure Firewall. Valid values are 'AZFW_VNet' and 'AZFW_Hub'."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the Azure Firewall."
  type        = map(string)
  default     = {}
}

variable "sku_tier" {
  description = "The SKU tier for the Azure Firewall. Valid values are 'Standard' and 'Premium'."
  type        = string
}

variable "ip_configuration_name" {
  description = "The name of the IP configuration for the Azure Firewall."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet in which to create the Azure Firewall."
  type        = string
}

variable "public_ip_address_id" {
  description = "The ID of the public IP address to associate with the Azure Firewall."
  type        = string
}

variable "firewall_policy_id" {
  description = "The ID of the Azure Firewall Policy to associate with the Azure Firewall."
  type        = string
  default     = null
}