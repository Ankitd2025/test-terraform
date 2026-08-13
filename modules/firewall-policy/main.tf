resource "azurerm_firewall_policy" "azurerm_firewall_policy" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  tags                = var.tags
  # insights {
  #   enabled                            = true
  #   default_log_analytics_workspace_id = var.log_analytics_workspace_id
  #   retention_in_days                   = var.log_analytics_retention_in_days
  # }
  intrusion_detection { mode = var.intrusion_detection_mode }
}
