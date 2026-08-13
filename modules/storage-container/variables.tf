variable "name" {
  description = "The name of the Storage Account container."
  type        = string
}

variable "storage_account_id" {
  description = "The ID of the Storage Account where the container will be created."
  type        = string
}

variable "container_access_type" {
  description = "The access level configured for the Storage Account container."
  type        = string
  default     = "private"
}