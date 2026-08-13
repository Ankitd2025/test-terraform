# Outputs for the Private DNS Zone module
output "azurerm_private_dns_zone_id" {
  description = "The ID of the Private DNS Zone."
  value       = azurerm_private_dns_zone.azurerm_private_dns_zone.id
}

output "azurerm_private_dns_zone_name" {
  description = "The name of the Private DNS Zone."
  value       = azurerm_private_dns_zone.azurerm_private_dns_zone.name
}