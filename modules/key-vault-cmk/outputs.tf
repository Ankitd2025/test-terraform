# Output for the Azure Key Vault Secret Management with Customer-Managed Keys (CMK) module

output "key_vault_cmk_key_id" {
  description = "The ID of the key created in Azure Key Vault for Customer-Managed Keys (CMK)."
  value       = azurerm_key_vault_key.azurerm_key_vault_key.id
}

output "key_vault_cmk_key_versionless_id" {
  description = "The ID of the key created in Azure Key Vault for Customer-Managed Keys (CMK) without the version."
  value       = replace(azurerm_key_vault_key.azurerm_key_vault_key.id, "/${azurerm_key_vault_key.azurerm_key_vault_key.version}", "")
}