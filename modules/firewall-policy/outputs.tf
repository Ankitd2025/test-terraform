# Output for the Firewall Policy module.
output "firewall_policy_id" {
  description = "The ID of the Azure Firewall Policy."
  value       = azurerm_firewall_policy.azurerm_firewall_policy.id
}

output "firewall_policy_name" {
  description = "The name of the Azure Firewall Policy."
  value       = azurerm_firewall_policy.azurerm_firewall_policy.name
}