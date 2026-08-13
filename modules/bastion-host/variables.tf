# Variabled for Bastion Host module
variable "name" {
  description = "Name of the Bastion Host"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where the Bastion Host will be created"
  type        = string
}

variable "location" {
  description = "Azure region where the Bastion Host will be created"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the Bastion Host"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "ID of the subnet where the Bastion Host will be deployed"
  type        = string
}

variable "public_ip_address_id" {
  description = "ID of the public IP address to be associated with the Bastion Host"
  type        = string
}

variable "sku" {
  description = "SKU of the Bastion Host (Basic or Standard)"
  type        = string
  default     = "Standard"
}

variable "copy_paste_enabled" {
  description = "Enable or disable copy-paste functionality in the Bastion Host"
  type        = bool
  default     = true
}

variable "file_copy_enabled" {
  description = "Enable or disable file copy functionality in the Bastion Host"
  type        = bool
  default     = true
}

variable "ip_connect_enabled" {
  description = "Enable or disable IP connect functionality in the Bastion Host"
  type        = bool
  default     = true
}

variable "shareable_link_enabled" {
  description = "Enable or disable shareable link functionality in the Bastion Host"
  type        = bool
  default     = true
}

variable "tunneling_enabled" {
  description = "Enable or disable tunneling functionality in the Bastion Host"
  type        = bool
  default     = true
}

