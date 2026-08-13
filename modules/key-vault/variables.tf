# Variables for the Azure Key Vault

variable "name" {
  description = "The name of the Key Vault."
  type        = string
}

variable "location" {
  description = "The location of the Key Vault."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Key Vault."
  type        = string
}

variable "tenant_id" {
  description = "The tenant ID of the Key Vault."
  type        = string
}

variable "sku_name" {
  description = "The SKU name of the Key Vault."
  type        = string
}

variable "public_network_access_enabled" {
  description = "Whether to enable public network access for the Key Vault."
  type        = bool
  default     = false
}

variable "rbac_authorization_enabled" {
  description = "Whether to enable RBAC authorization for the Key Vault."
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "The number of days to retain deleted Key Vaults."
  type        = number
  default     = 90
}

variable "tags" {
  description = "A map of tags to assign to the Key Vault."
  type        = map(string)
}

variable "purge_protection_enabled" {
  description = "Whether to enable purge protection for the Key Vault."
  type        = bool
}


variable "principal_id" {
  description = "RBAC Policy principal Id"
  type        = string
}

