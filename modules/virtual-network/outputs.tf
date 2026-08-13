# Outputs for the Azure Virtual Network

output "id" {
  description = "The ID of the virtual network."
  value       = azurerm_virtual_network.azurerm_virtual_network.id
}

output "name" {
  description = "The name of the virtual network."
  value       = azurerm_virtual_network.azurerm_virtual_network.name
}

output "location" {
  description = "The location of the virtual network."
  value       = azurerm_virtual_network.azurerm_virtual_network.location
}

output "resource_group_name" {
  description = "The name of the resource group in which the virtual network is created."
  value       = azurerm_virtual_network.azurerm_virtual_network.resource_group_name
}