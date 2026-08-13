output "managed_redis_id" {
  description = "The ID of Azure Managed Redis."
  value       = azurerm_managed_redis.azurerm_managed_redis.id
}

output "managed_redis_name" {
  description = "The name of Azure Managed Redis."
  value       = azurerm_managed_redis.azurerm_managed_redis.name
}

output "managed_redis_hostname" {
  description = "The hostname of Azure Managed Redis."
  value       = azurerm_managed_redis.azurerm_managed_redis.hostname
}

output "managed_redis_ssl_port" {
  description = "The encrypted port of Azure Managed Redis."
  value       = azurerm_managed_redis.azurerm_managed_redis.default_database[0].port
}

output "managed_redis_primary_access_key" {
  description = "The primary access key of Azure Managed Redis."
  value       = azurerm_managed_redis.azurerm_managed_redis.default_database[0].primary_access_key
  sensitive   = true
}

output "managed_redis_secondary_access_key" {
  description = "The secondary access key of Azure Managed Redis."
  value       = azurerm_managed_redis.azurerm_managed_redis.default_database[0].secondary_access_key
  sensitive   = true
}
