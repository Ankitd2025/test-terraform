output "firewall_policy_rule_collection_group_id" {
  description = "The ID of the Firewall Policy Rule Collection Group."
  value       = azurerm_firewall_policy_rule_collection_group.azurerm_firewall_policy_rule_collection_group.id
}

output "firewall_policy_rule_collection_group_name" {
  description = "The name of the Firewall Policy Rule Collection Group."
  value       = azurerm_firewall_policy_rule_collection_group.azurerm_firewall_policy_rule_collection_group.name
}
