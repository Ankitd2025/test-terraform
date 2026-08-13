# Variabled for the VPN Gateway module
variable "name" {
  description = "The name of the VPN Gateway."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the VPN Gateway."
  type        = string
}

variable "location" {
  description = "The location/region where the VPN Gateway will be created."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the VPN Gateway."
  type        = map(string)
  default     = {}
}

variable "bgp_enabled" {
  description = "Indicates whether BGP is enabled for the VPN Gateway."
  type        = bool
  default     = false
}

variable "type" {
  description = "The type of the VPN Gateway. Valid values are 'Vpn' and 'ExpressRoute'."
  type        = string
}

variable "vpn_type" {
  description = "The VPN type of the VPN Gateway. Valid values are 'RouteBased' and 'PolicyBased'."
  type        = string
}

variable "active_active" {
  description = "Indicates whether the VPN Gateway is active-active. This is only applicable for RouteBased VPN Gateways."
  type        = bool
  default     = false
}

variable "sku" {
  description = "The SKU of the VPN Gateway. Valid values are 'Basic', 'VpnGw1', 'VpnGw2', 'VpnGw3', 'VpnGw4', and 'VpnGw5'."
  type        = string
}

variable "ip_configuration_name" {
  description = "The name of the IP configuration for the VPN Gateway."
  type        = string
}

variable "public_ip_address_id" {
  description = "The ID of the public IP address to associate with the VPN Gateway."
  type        = string
}

variable "private_ip_address_allocation" {
  description = "The method to use for allocating the private IP address. Valid values are 'Dynamic' and 'Static'."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to which the VPN Gateway will be connected."
  type        = string
}