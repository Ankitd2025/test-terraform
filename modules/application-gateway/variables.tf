variable "name" {
  description = "The name of the Application Gateway."
  type        = string
}

variable "public_ip_name" {
  description = "The name of the public IP address used by the Application Gateway."
  type        = string
}

variable "identity_name" {
  description = "The name of the user-assigned managed identity used by the Application Gateway."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The Azure region where the Application Gateway will be created."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the Application Gateway subnet."
  type        = string
}

variable "private_ip_address" {
  description = "The static private frontend IP address for the Application Gateway."
  type        = string
}

variable "sku_name" {
  description = "The Application Gateway SKU name. Keep WAF_v2 for WAF-enabled deployments."
  type        = string
  default     = "WAF_v2"
}

variable "autoscale_min_capacity" {
  description = "The minimum autoscale capacity for the Application Gateway."
  type        = number
  default     = 1
}

variable "autoscale_max_capacity" {
  description = "The maximum autoscale capacity for the Application Gateway."
  type        = number
  default     = 2
}

variable "waf_firewall_mode" {
  description = "The WAF firewall mode."
  type        = string
  default     = "Prevention"
}

variable "key_vault_id" {
  description = "The Key Vault ID used for certificate access RBAC."
  type        = string
  default     = null
}

variable "key_vault_certificate_secret_id" {
  description = "The Key Vault certificate secret ID for HTTPS listeners. Leave null to create HTTP listeners only while still assigning Key Vault RBAC."
  type        = string
  default     = null
}

variable "zones" {
  description = "The availability zones for the Application Gateway."
  type        = list(string)
  default     = ["1", "2"]
}

variable "public_ip_zones" {
  description = "The availability zones for the Application Gateway public IP."
  type        = list(string)
  default     = ["1", "2"]
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}
