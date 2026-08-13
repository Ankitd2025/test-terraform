# Variables for the federated identity credential module
variable "name" {
  description = "The name of the federated identity credential."
  type        = string
}

variable "user_assigned_identity_id" {
  description = "The ID of the user-assigned managed identity to which the federated identity credential will be associated."
  type        = string
}

variable "issuer" {
  description = "The issuer of the federated identity credential."
  type        = string
}

variable "subject" {
  description = "The subject of the federated identity credential."
  type        = string
}

variable "audience" {
  description = "The audience of the federated identity credential."
  type        = list(string)
}