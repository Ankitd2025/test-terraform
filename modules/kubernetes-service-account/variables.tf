# Variables for the Kubernetes service account module
variable "name" {
  description = "The name of the Kubernetes service account."
  type        = string
}

variable "namespace" {
  description = "The namespace in which the Kubernetes service account will be created."
  type        = string
}

variable "client_id" {
  description = "The client ID of the Azure AD application associated with the Kubernetes service account."
  type        = string
}