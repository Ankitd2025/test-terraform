output "application_insights_id" {
  description = "The ID of Application Insights"
  value       = azurerm_application_insights.azurerm_application_insights.id
}

output "application_insights_name" {
  description = "The Name of Application Insights"
  value       = azurerm_application_insights.azurerm_application_insights.name
}

output "application_insights_app_id" {
  description = "The App ID of Application Insights"
  value       = azurerm_application_insights.azurerm_application_insights.app_id
}

output "application_insights_instrumentation_key" {
  description = "The Instrumentation Key of Application Insights"
  value       = azurerm_application_insights.azurerm_application_insights.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "The Connection String of Application Insights"
  value       = azurerm_application_insights.azurerm_application_insights.connection_string
  sensitive   = true
}