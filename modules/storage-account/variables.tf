# Variables for the Storage Account module
variable "name" {
  description = "The name of the Storage Account."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Storage Account."
  type        = string
}

variable "location" {
  description = "The Azure region where the Storage Account will be created."
  type        = string
}

variable "account_tier" {
  description = "The performance tier of the Storage Account (Standard or Premium)."
  type        = string
}

variable "account_replication_type" {
  description = "The replication strategy for the Storage Account (LRS, GRS, RA-GRS, ZRS)."
  type        = string
}

variable "enable_https_traffic_only" {
  description = "Whether to allow only HTTPS traffic to the Storage Account."
  type        = bool
}

variable "account_kind" {
  description = "The kind of the Storage Account (StorageV2, BlobStorage, FileStorage, BlockBlobStorage)."
  type        = string
}

variable "public_network_access_enabled" {
  description = "Whether to allow public network access to the Storage Account."
  type        = bool
}

variable "min_tls_version" {
  description = "The minimum TLS version to be permitted on the Storage Account (TLS1_0, TLS1_1, TLS1_2)."
  type        = string
}

variable "https_traffic_only_enabled" {
  description = "Whether to allow only HTTPS traffic to the Storage Account."
  type        = bool
}

variable "allow_nested_items_to_be_public" {
  description = "Whether to allow nested items (e.g., blobs, files) to be public when the Storage Account is private."
  type        = bool
}

variable "shared_access_key_enabled" {
  description = "Whether to enable shared access key authentication for the Storage Account."
  type        = bool
}

variable "versioning_enabled" {
  description = "Whether to enable blob versioning for the Storage Account."
  type        = bool
}

variable "container_delete_retention_policy_days" {
  description = "The number of days to retain deleted containers in the Storage Account (0 to disable)."
  type        = number
}

variable "delete_retention_policy_days" {
  description = "The number of days to retain deleted blobs in the Storage Account (0 to disable)."
  type        = number
}

variable "network_rules_bypass" {
  description = "A comma-separated list of Azure services that can bypass the network rules (e.g., 'AzureServices')."
  type        = list(string)
}

variable "network_rules_default_action" {
  description = "The default action for network rules (Allow or Deny)."
  type        = string
}

variable "network_rules_virtual_network_subnet_ids" {
  description = "A list of virtual network subnet IDs that are allowed to access the Storage Account when the default action is Deny."
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the Storage Account."
  type        = map(string)
}

