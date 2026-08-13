# Output for the Azure Public IP Address
output "public_ip_address_id" {
  description = "The ID of the public IP address."
  value       = azurerm_public_ip.azurerm_public_ip.id
}

output "public_ip_address_name" {
  description = "The name of the public IP address."
  value       = azurerm_public_ip.azurerm_public_ip.name
}

output "public_ip_address_ip_address" {
  description = "The IP address of the public IP address."
  value       = azurerm_public_ip.azurerm_public_ip.ip_address
}