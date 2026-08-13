variable "name" {
  description = "The name of the Key Vault secret."
  type        = string
}

variable "value" {
  description = "The value of the Key Vault secret."
  type        = string
  sensitive   = true
}

variable "key_vault_id" {
  description = "The ID of the Key Vault in which to create the secret."
  type        = string
}

variable "content_type" {
  description = "The content type of the Key Vault secret."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the Key Vault secret."
  type        = map(string)
  default     = {}
}
