# Variables for the Azure Virtual Network
variable "virtual_network_name" {
  description = "The name of the virtual network."
  type        = string
}

variable "location" {
  description = "The location of the virtual network."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual network."
  type        = string
}

variable "storage_account_id" {
  description = "The ID of the storage account to use for flow logs."
  type        = string
}

variable "workspace_id" {
  description = "The ID of the Log Analytics workspace to use for diagnostic settings."
  type        = string
}

variable "workspace_region" {
  description = "The region of the Log Analytics workspace for traffic analytics."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
}

variable "enable_diagnostic" {
  description = "Whether to enable diagnostic settings for the virtual network."
  type        = bool
  default     = false
}

variable "enable_flow_log" {
  description = "Whether to enable flow logs for the virtual network."
  type        = bool
  default     = false
}

variable "workspace_resource_id" {
  description = "The resource ID of the Log Analytics workspace for traffic analytics."
  type        = string
}

variable "virtual_network_id" {
  description = "The ID of the virtual network for flow logs."
  type        = string
}

variable "nw_resource_group_name" {
  description = "The name of the resource group in which to create the Network Watcher."
  type        = string
}