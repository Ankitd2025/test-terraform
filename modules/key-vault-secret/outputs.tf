output "key_vault_secret_id" {
  description = "The ID of the Key Vault secret."
  value       = azurerm_key_vault_secret.azurerm_key_vault_secret.id
}

output "key_vault_secret_name" {
  description = "The name of the Key Vault secret."
  value       = azurerm_key_vault_secret.azurerm_key_vault_secret.name
}

output "key_vault_secret_version" {
  description = "The version of the Key Vault secret."
  value       = azurerm_key_vault_secret.azurerm_key_vault_secret.version
}
