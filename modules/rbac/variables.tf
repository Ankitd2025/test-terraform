# Variable for the RBAC role assignment
variable "scope" {
  description = "The scope at which the role assignment applies. This can be a subscription, resource group, or individual resource."
  type        = string
}

variable "role_definition_name" {
  description = "The name of the role definition to assign (e.g., 'Contributor', 'Reader', 'Owner')."
  type        = string
}

variable "principal_id" {
  description = "The principal ID of the user, group, or service principal to which the role will be assigned."
  type        = string
}
