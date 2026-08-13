variable "name" {
  description = "The name of the PostgreSQL server."
  type        = string
}

variable "location" {
  description = "The location of the PostgreSQL server."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "server_version" {
  description = "The version of the PostgreSQL server."
  type        = string
}

variable "delegated_subnet_id" {
  description = "The ID of the delegated subnet."
  type        = string
}

variable "private_dns_zone_id" {
  description = "The ID of the private DNS zone."
  type        = string
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  type        = bool
}

variable "administrator_login" {
  description = "The administrator login for the PostgreSQL server."
  type        = string
}

variable "administrator_password" {
  description = "The administrator password for the PostgreSQL server."
  type        = string
}

variable "zone" {
  description = "The availability zone of the PostgreSQL server."
  type        = string
}

variable "storage_mb" {
  description = "The storage size in MB."
  type        = number
}

variable "storage_tier" {
  description = "The storage tier."
  type        = string
}

variable "sku_name" {
  description = "The SKU name of the PostgreSQL server."
  type        = string
}
variable "high_availability_mode" {
  description = "The high availability mode of the PostgreSQL server."
  type        = string
  default     = ""
}

variable "database_name" {
  description = "The name of the PostgreSQL database."
  type        = string
}
variable "database_collation" {
  description = "The collation of the PostgreSQL database."
  type        = string
}
variable "database_charset" {
  description = "The character set of the PostgreSQL database."
  type        = string
}
variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
