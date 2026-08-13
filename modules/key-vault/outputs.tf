# Outputs for Key Vault module

output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.azurerm_key_vault.id
}

output "key_vault_name" {
  description = "The name of the Key Vault."
  value       = azurerm_key_vault.azurerm_key_vault.name
}

output "key_vault_location" {
  description = "The location of the Key Vault."
  value       = azurerm_key_vault.azurerm_key_vault.location
}