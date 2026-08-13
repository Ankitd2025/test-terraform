# Output for the VPN Gateway module.
output "vpn_gateway_id" {
  description = "The ID of the VPN Gateway."
  value       = azurerm_virtual_network_gateway.azurerm_virtual_network_gateway.id
}

output "vpn_gateway_name" {
  description = "The name of the VPN Gateway."
  value       = azurerm_virtual_network_gateway.azurerm_virtual_network_gateway.name
}

output "vpn_gateway_resource_group_name" {
  description = "The name of the resource group in which the VPN Gateway is created."
  value       = azurerm_virtual_network_gateway.azurerm_virtual_network_gateway.resource_group_name
}

output "vpn_gateway_location" {
  description = "The location/region where the VPN Gateway is created."
  value       = azurerm_virtual_network_gateway.azurerm_virtual_network_gateway.location
}