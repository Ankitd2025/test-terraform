resource "azurerm_management_lock" "azurerm_management_lock" {
  # Best Practice: Only enable locks in Production environments
  count      = var.enable_resource_lock ? 1 : 0
  name       = "lock-${var.name}"
  scope      = azurerm_log_analytics_workspace.azurerm_log_analytics_workspace.id
  lock_level = "CanNotDelete"
}
