# Variables for the Disk Encryption Set module
variable "name" {
  description = "The name of the Disk Encryption Set."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Disk Encryption Set."
  type        = string
}

variable "location" {
  description = "The location/region where the Disk Encryption Set will be created."
  type        = string
}

variable "key_vault_key_id" {
  description = "The ID of the Key Vault key to be used for the Disk Encryption Set."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the Disk Encryption Set."
  type        = map(string)
}