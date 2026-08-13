resource "azurerm_log_analytics_workspace" "azurerm_log_analytics_workspace" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  sku                             = var.sku
  retention_in_days               = var.retention_in_days
  internet_ingestion_enabled      = var.internet_ingestion_enabled
  internet_query_enabled          = var.internet_query_enabled
  local_authentication_enabled    = var.local_authentication_enabled
  allow_resource_only_permissions = var.allow_resource_only_permissions
  cmk_for_query_forced            = var.cmk_for_query_forced
  tags                            = var.tags
  daily_quota_gb                  = var.daily_quota_gb
  identity {
    type = var.identity_type
  }
}
