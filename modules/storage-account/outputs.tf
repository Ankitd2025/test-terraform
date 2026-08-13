# Outputs for the storage account module
output "storage_account_id" {
  description = "The ID of the Storage Account."
  value       = azurerm_storage_account.azurerm_storage_account.id
}

output "storage_account_name" {
  description = "The name of the Storage Account."
  value       = azurerm_storage_account.azurerm_storage_account.name
}

output "storage_account_identity" {
  description = "The Identity of the Storage Account"
  value       = azurerm_storage_account.azurerm_storage_account.identity
}

output "storage_account_uri" {
  description = "The URI of the Storage Account."
  value       = azurerm_storage_account.azurerm_storage_account.primary_blob_endpoint
}