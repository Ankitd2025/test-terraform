resource "azurerm_key_vault" "azurerm_key_vault" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  tenant_id                     = var.tenant_id
  sku_name                      = var.sku_name
  public_network_access_enabled = var.public_network_access_enabled
  rbac_authorization_enabled    = var.rbac_authorization_enabled
  soft_delete_retention_days    = var.soft_delete_retention_days
  purge_protection_enabled      = var.purge_protection_enabled
  tags                          = var.tags
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }
}
