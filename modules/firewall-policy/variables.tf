# Variables for Azure Firewall Policy module
variable "name" {
  description = "The name of the Azure Firewall Policy."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Azure Firewall Policy."
  type        = string
}

variable "location" {
  description = "The location/region where the Azure Firewall Policy will be created."
  type        = string
}

variable "sku" {
  description = "The SKU of the Azure Firewall Policy."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the Azure Firewall Policy."
  type        = map(string)
  default     = {}
}

variable "intrusion_detection_mode" {
  description = "The mode for intrusion detection. Valid values are 'Alert' and 'Deny'."
  type        = string
  default     = "Deny"
}

# variable "log_analytics_workspace_id" {
#   description = "The resource ID of the Log Analytics workspace for Azure Firewall Policy diagnostics."
#   type        = string
# }

# variable "log_analytics_retention_in_days" {
#   description = "The retention period in days for logs sent to the Log Analytics workspace."
#   type        = number
# }