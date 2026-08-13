# Variables for the Azure Container Registry module
variable "name" {
  description = "The name of the Container Registry."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Container Registry."
  type        = string
}

variable "location" {
  description = "The Azure region where the Container Registry will be created."
  type        = string
}

variable "sku" {
  description = "The SKU of the Container Registry. Valid values are Basic, Standard, and Premium. Geo-replication requires Premium."
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "The sku value must be Basic, Standard, or Premium."
  }
}

variable "admin_enabled" {
  description = "Whether the admin user is enabled for the Container Registry."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the Container Registry."
  type        = bool
  default     = false
}

variable "quarantine_policy_enabled" {
  description = "Whether quarantine policy is enabled for the Container Registry. This requires the Premium SKU."
  type        = bool
  default     = false
}

variable "zone_redundancy_enabled" {
  description = "Whether zone redundancy is enabled for the Container Registry. This requires the Premium SKU."
  type        = bool
  default     = false
}

variable "anonymous_pull_enabled" {
  description = "Whether anonymous pull access is enabled for the Container Registry."
  type        = bool
  default     = false
}

variable "data_endpoint_enabled" {
  description = "Whether dedicated data endpoints are enabled for the Container Registry. This requires the Premium SKU."
  type        = bool
  default     = false
}

variable "geo_replications" {
  description = "Optional geo-replication locations for the Container Registry. Leave empty to create no geo-replications. Geo-replication requires the Premium SKU."
  type = list(object({
    location                  = string
    regional_endpoint_enabled = optional(bool, true)
    zone_redundancy_enabled   = optional(bool, false)
    tags                      = optional(map(string), null)
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to the Container Registry."
  type        = map(string)
  default     = {}
}

