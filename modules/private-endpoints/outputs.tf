# Output for the Private Endpoints module
output "private_endpoint_id" {
  description = "The ID of the Private Endpoint."
  value       = azurerm_private_endpoint.azurerm_private_endpoint.id
}

output "private_endpoint_ip_addresses" {
  description = "The private IP addresses assigned to the Private Endpoint."
  value       = azurerm_private_endpoint.azurerm_private_endpoint.private_service_connection[0].private_ip_address
}

output "private_endpoint_nic_id" {
  description = "The network interface card (NIC) associated with the Private Endpoint."
  value       = azurerm_private_endpoint.azurerm_private_endpoint.network_interface
}

output "private_endpoint_name" {
  description = "The name of the Private Endpoint."
  value       = azurerm_private_endpoint.azurerm_private_endpoint.name
}