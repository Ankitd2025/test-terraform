# Variables for Azure Application Insights


variable "application_insights_name_override" {
  type        = string
  description = "Optional override for the Application Insights name"
  default     = null
}

variable "location" {
  type        = string
  description = "The Value for the Location of Application Insights"
}

variable "name" {
  type        = string
  description = "The name of the Application Insights instance"
}

variable "resource_group_name" {
  type        = string
  description = "The Value for the Resource Group Name to which Application Insights will be associated"
}

variable "application_type" {
  type        = string
  description = "The Application Insights application type"
  default     = "web"
}

variable "workspace_id" {
  type        = string
  description = "Optional Log Analytics Workspace resource ID for workspace-based Application Insights"
  default     = null
}

variable "daily_data_cap_in_gb" {
  type        = number
  description = "The daily data volume cap in GB"
  default     = 100
}

variable "retention_in_days" {
  type        = number
  description = "The data retention period in days"
  default     = 90
}

variable "sampling_percentage" {
  type        = number
  description = "The sampling percentage for telemetry"
  default     = 100
}

variable "internet_ingestion_enabled" {
  type        = bool
  description = "Enable or disable internet ingestion for Application Insights"
  default     = false
}

variable "internet_query_enabled" {
  type        = bool
  description = "Enable or disable internet query for Application Insights"
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the Azure Firewall."
  type        = map(string)
  default     = {}
}
