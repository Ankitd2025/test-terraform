# Outputs for the Azure Log Analytics Workspace
output "log_analytics_workspace_resource_id" {
  description = "The resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.azurerm_log_analytics_workspace.id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.azurerm_log_analytics_workspace.name
}

output "log_analytics_workspace_id" {
  description = "The workspace ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.azurerm_log_analytics_workspace.workspace_id
}

output "log_analytics_workspace_identity_principal_id" {
  description = "The principal ID of the Log Analytics workspace identity."
  value       = azurerm_log_analytics_workspace.azurerm_log_analytics_workspace.identity[0].principal_id
}