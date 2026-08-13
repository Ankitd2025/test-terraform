# Variables for the Azure Log Analytics Workspace
variable "name" {
  description = "The name of the Log Analytics workspace."
  type        = string
}

variable "location" {
  description = "The location of the Log Analytics workspace."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Log Analytics workspace."
  type        = string
}

variable "sku" {
  description = "The SKU of the Log Analytics workspace."
  type        = string
}

variable "retention_in_days" {
  description = "The retention period for the Log Analytics workspace in days."
  type        = number
}

variable "internet_ingestion_enabled" {
  description = "Whether to enable internet ingestion for the Log Analytics workspace."
  type        = bool
  default     = false
}

variable "internet_query_enabled" {
  description = "Whether to enable internet query for the Log Analytics workspace."
  type        = bool
  default     = false
}

variable "local_authentication_enabled" {
  description = "Whether to enable local authentication for the Log Analytics workspace."
  type        = bool
  default     = false
}

variable "allow_resource_only_permissions" {
  description = "Whether to allow resource-only permissions for the Log Analytics workspace."
  type        = bool
  default     = false
}

variable "cmk_for_query_forced" {
  description = "Whether to force customer-managed keys for query in the Log Analytics workspace."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
}

variable "identity_type" {
  description = "The type of identity to use for the Log Analytics workspace."
  type        = string
  default     = "SystemAssigned"
}

variable "enable_diagnostic" {
  description = "Whether to enable diagnostic settings for the Log Analytics workspace."
  type        = bool
  default     = false
}

variable "enable_resource_lock" {
  description = "Whether to enable a management lock on the resource group to prevent accidental deletion. Best Practice: Only enable locks in Production environments."
  type        = bool
  default     = false
}

variable "daily_quota_gb" {
  description = "The daily quota in GB for the Log Analytics workspace."
  type        = number
}