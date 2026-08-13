resource "azurerm_role_assignment" "azurerm_role_assignment" {
  scope                = azurerm_key_vault.azurerm_key_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.principal_id
}