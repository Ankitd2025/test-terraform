# Output for the Azure Firewall
output "firewall_id" {
  description = "The ID of the Azure Firewall."
  value       = azurerm_firewall.azurerm_firewall.id
}

output "firewall_name" {
  description = "The name of the Azure Firewall."
  value       = azurerm_firewall.azurerm_firewall.name
}

output "firewall_resource_group_name" {
  description = "The name of the resource group in which the Azure Firewall is created."
  value       = azurerm_firewall.azurerm_firewall.resource_group_name
}

output "firewall_location" {
  description = "The location/region where the Azure Firewall is created."
  value       = azurerm_firewall.azurerm_firewall.location
}

output "firewall_private_ip" {
  description = "The Private IP address of the Firewall"
  value = azurerm_firewall.azurerm_firewall.ip_configuration[0].private_ip_address
}