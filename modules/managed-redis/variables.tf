variable "name" {
  description = "The name of the Azure Managed Redis cache."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create Azure Managed Redis."
  type        = string
}

variable "location" {
  description = "The Azure region where Azure Managed Redis will be created."
  type        = string
}

variable "sku_name" {
  description = "The Azure Managed Redis SKU name. Use Enterprise_E5 for the E5 Enterprise tier."
  type        = string
  default     = "Enterprise_E5"
}

variable "high_availability_enabled" {
  description = "Whether high availability is enabled for Azure Managed Redis."
  type        = bool
  default     = false
}

variable "public_network_access" {
  description = "The public network access setting for Azure Managed Redis."
  type        = string
  default     = "Disabled"
}

variable "access_keys_authentication_enabled" {
  description = "Whether access key authentication is enabled for the default Redis database."
  type        = bool
  default     = true
}

variable "client_protocol" {
  description = "The client protocol for the default Redis database."
  type        = string
  default     = "Encrypted"
}

variable "clustering_policy" {
  description = "The clustering policy for the default Redis database."
  type        = string
  default     = "EnterpriseCluster"
}

variable "eviction_policy" {
  description = "The eviction policy for the default Redis database."
  type        = string
  default     = "VolatileLRU"
}

variable "tags" {
  description = "A map of tags to assign to Redis."
  type        = map(string)
  default     = {}
}

variable "key_vault_key_id" {
  description = "The Key Vault key ID for customer-managed keys."
  type        = string
}

variable "user_assigned_identity_id" {
  description = "The user-assigned identity ID for customer-managed keys."
  type        = string
}