variable "name" {
  description = "The name of the Firewall Policy Rule Collection Group."
  type        = string
}

variable "firewall_policy_id" {
  description = "The ID of the Azure Firewall Policy where rule collections will be created."
  type        = string
}

variable "priority" {
  description = "The priority of the Firewall Policy Rule Collection Group. Must be unique within the policy."
  type        = number
}

variable "application_rule_collections" {
  description = "Application rule collections for the Firewall Policy Rule Collection Group."
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name                  = string
      source_addresses      = optional(list(string), null)
      source_ip_groups      = optional(list(string), null)
      destination_addresses = optional(list(string), null)
      destination_fqdns     = optional(list(string), null)
      destination_fqdn_tags = optional(list(string), null)
      destination_urls      = optional(list(string), null)
      terminate_tls         = optional(bool, false)
      web_categories        = optional(list(string), null)
      protocols = list(object({
        type = string
        port = number
      }))
    }))
  }))
  default = []
}

variable "network_rule_collections" {
  description = "Network rule collections for the Firewall Policy Rule Collection Group."
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name                  = string
      protocols             = list(string)
      source_addresses      = optional(list(string), null)
      source_ip_groups      = optional(list(string), null)
      destination_addresses = optional(list(string), null)
      destination_fqdns     = optional(list(string), null)
      destination_ip_groups = optional(list(string), null)
      destination_ports     = list(string)
    }))
  }))
  default = []
}

variable "nat_rule_collections" {
  description = "NAT rule collections for the Firewall Policy Rule Collection Group."
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name                = string
      protocols           = list(string)
      source_addresses    = optional(list(string), null)
      source_ip_groups    = optional(list(string), null)
      destination_address = string
      destination_ports   = list(string)
      translated_address  = optional(string, null)
      translated_fqdn     = optional(string, null)
      translated_port     = string
    }))
  }))
  default = []
}
