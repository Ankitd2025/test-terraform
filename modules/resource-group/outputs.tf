# Outputs for the Azure Resource Group

output "resource_group_id" {
  description = "The ID of the resource group."
  value       = azurerm_resource_group.azurerm_resource_group.id
}

output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.azurerm_resource_group.name
}

output "resource_group_location" {
  description = "The location of the resource group."
  value       = azurerm_resource_group.azurerm_resource_group.location
}

output "resource_group_tags" {
  description = "The tags assigned to the resource group."
  value       = azurerm_resource_group.azurerm_resource_group.tags
}