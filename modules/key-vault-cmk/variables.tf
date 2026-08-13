# Variables for the Azure Key Vault Secret Management with Customer-Managed Keys (CMK) module
variable "name" {
  description = "The name of the Azure Key Vault instance."
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the Azure Key Vault instance."
  type        = string
}

variable "key_type" {
  description = "The type of the key to be created in Azure Key Vault (e.g., RSA, EC)."
  type        = string
}

variable "key_size" {
  description = "The size of the key to be created in Azure Key Vault (e.g., 2048, 3072, 4096 for RSA)."
  type        = number
}

variable "key_opts" {
  description = "A list of operations that the key can perform (e.g., encrypt, decrypt, sign, verify)."
  type        = list(string)
}

variable "notify_before_expiry" {
  description = "The time before the key expires when a notification will be sent (e.g., 'P7D' for 7 days)."
  type        = string
}

variable "expire_after" {
  description = "The duration after which the key will expire (e.g., 'P365D' for 365 days)."
  type        = string
}

variable "time_after_creation" {
  description = "The time after the key is created when the rotation policy will trigger (e.g., 'P30D' for 30 days)."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the Azure Key Vault instance."
  type        = map(string)
}

