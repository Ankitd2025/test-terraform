output "storage_container_id" {
  description = "The ID of the Storage Account container."
  value       = azurerm_storage_container.azurerm_storage_container.id
}

output "storage_container_name" {
  description = "The name of the Storage Account container."
  value       = azurerm_storage_container.azurerm_storage_container.name
}

output "storage_container_resource_manager_id" {
  description = "The Resource Manager ID of the Storage Account container."
  value       = azurerm_storage_container.azurerm_storage_container.id
}

output "storage_container_url" {
  description = "The URL of the Storage Account container."
  value       = azurerm_storage_container.azurerm_storage_container.url
}