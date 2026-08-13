resource "azurerm_key_vault_key" "azurerm_key_vault_key" {
  name         = var.name
  key_vault_id = var.key_vault_id
  key_type     = var.key_type
  key_size     = var.key_size
  key_opts     = var.key_opts
  tags         = var.tags
  rotation_policy {
    automatic {
      time_after_creation = var.time_after_creation
    }
    notify_before_expiry = var.notify_before_expiry
    expire_after         = var.expire_after
  }
}
