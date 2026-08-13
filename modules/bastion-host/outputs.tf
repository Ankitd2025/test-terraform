# Azure Bastion Module - Outputs
output "id" {
  description = "The ID of the Bastion Host."
  value       = azurerm_bastion_host.azurerm_bastion_host.id
}

output "name" {
  description = "The name of the Bastion Host."
  value       = azurerm_bastion_host.azurerm_bastion_host.name
}

output "dns_name" {
  description = "The DNS name of the Bastion Host."
  value       = azurerm_bastion_host.azurerm_bastion_host.dns_name
}

output "location" {
  description = "The location of the Bastion Host."
  value       = azurerm_bastion_host.azurerm_bastion_host.location
}

output "resource_group_name" {
  description = "The resource group name of the Bastion Host."
  value       = azurerm_bastion_host.azurerm_bastion_host.resource_group_name
}
