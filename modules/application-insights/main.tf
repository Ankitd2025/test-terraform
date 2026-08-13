resource "azurerm_application_insights" "azurerm_application_insights" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  application_type           = var.application_type
  workspace_id               = var.workspace_id
  daily_data_cap_in_gb       = var.daily_data_cap_in_gb
  retention_in_days          = var.retention_in_days
  sampling_percentage        = var.sampling_percentage
  internet_ingestion_enabled = var.internet_ingestion_enabled
  internet_query_enabled     = var.internet_query_enabled
}
