# Outputs for the Azure User Assigned Managed Identity module
output "user_assigned_identity_id" {
  description = "The ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.azurerm_user_assigned_identity.id
}

output "user_assigned_identity_name" {
  description = "The name of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.azurerm_user_assigned_identity.name
}

output "user_assigned_identity_client_id" {
  description = "The client ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.azurerm_user_assigned_identity.client_id
}

output "user_assigned_identity_principal_id" {
  description = "The principal ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.azurerm_user_assigned_identity.principal_id
}
