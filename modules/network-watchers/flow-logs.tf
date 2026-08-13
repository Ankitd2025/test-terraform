resource "azurerm_network_watcher_flow_log" "azurerm_network_watcher_flow_log" {
  name                 = "flowlog-${var.virtual_network_name}"
  network_watcher_name = "NetworkWatcher_${var.location}"
  resource_group_name  = var.nw_resource_group_name
  target_resource_id   = var.virtual_network_id
  enabled              = true
  storage_account_id   = var.storage_account_id
  tags                 = var.tags
  retention_policy {
    days    = 90
    enabled = true
  }
  traffic_analytics {
    enabled               = true
    workspace_id          = var.workspace_id
    workspace_region      = var.workspace_region
    workspace_resource_id = var.workspace_resource_id
  }
}
