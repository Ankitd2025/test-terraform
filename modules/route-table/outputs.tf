# Output for the Route Table module.
output "route_table_id" {
  description = "The ID of the Route Table."
  value       = azurerm_route_table.azurerm_route_table.id
}

output "route_table_name" {
  description = "The name of the Route Table."
  value       = azurerm_route_table.azurerm_route_table.name
}