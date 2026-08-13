resource "azurerm_storage_account" "azurerm_storage_account" {
  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  account_kind                    = var.account_kind
  public_network_access_enabled   = var.public_network_access_enabled
  min_tls_version                 = var.min_tls_version
  https_traffic_only_enabled      = var.https_traffic_only_enabled
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  shared_access_key_enabled       = var.shared_access_key_enabled
  blob_properties {
    versioning_enabled = var.versioning_enabled
    container_delete_retention_policy { days = var.container_delete_retention_policy_days }
    delete_retention_policy { days = var.delete_retention_policy_days }
  }
  network_rules {
    bypass                     = var.network_rules_bypass
    default_action             = var.network_rules_default_action
    virtual_network_subnet_ids = var.network_rules_virtual_network_subnet_ids
  }
  identity { type = "SystemAssigned" }
  tags = var.tags
  lifecycle {
    ignore_changes = [customer_managed_key]
  }
}
