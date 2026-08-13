# Outputs for the Azure Container Registry module
output "container_registry_id" {
  description = "The ID of the Container Registry."
  value       = azurerm_container_registry.azurerm_container_registry.id
}

output "container_registry_name" {
  description = "The name of the Container Registry."
  value       = azurerm_container_registry.azurerm_container_registry.name
}

output "container_registry_login_server" {
  description = "The login server URL of the Container Registry."
  value       = azurerm_container_registry.azurerm_container_registry.login_server
}

output "container_registry_admin_username" {
  description = "The admin username of the Container Registry when admin access is enabled."
  value       = azurerm_container_registry.azurerm_container_registry.admin_username
  sensitive   = true
}
