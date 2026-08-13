# Variables for the Helm release module
variable "name" {
  description = "The name of the Helm release."
  type        = string
}

variable "namespace" {
  description = "The namespace in which the Helm release will be deployed."
  type        = string
}

variable "repository" {
  description = "The Helm chart repository URL."
  type        = string
}

variable "chart" {
  description = "The name of the Helm chart to deploy."
  type        = string
}

variable "chart_version" {
  description = "The version of the Helm chart to deploy."
  type        = string
}

variable "set_values" {
  description = "Nested map of Helm values. Must use proper map nesting (not dot-notation keys) so yamlencode produces valid nested YAML."
  type        = any
}