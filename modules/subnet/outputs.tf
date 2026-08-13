# Outputs for Azure Subnet module
output "id" {
  description = "The ID of the subnet."
  value       = azurerm_subnet.azurerm_subnet.id
}

output "name" {
  description = "The name of the subnet."
  value       = azurerm_subnet.azurerm_subnet.name
}