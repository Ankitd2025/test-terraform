resource "azurerm_disk_encryption_set" "azurerm_disk_encryption_set" {
  name                      = lower("${var.name}")
  location                  = var.location
  resource_group_name       = var.resource_group_name
  key_vault_key_id          = var.key_vault_key_id
  auto_key_rotation_enabled = "true"
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}