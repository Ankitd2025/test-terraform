# Output for the Azure Managed Identity
output "azurerm_user_assigned_identity_id" {
  description = "The ID of the Managed Identity."
  value       = azurerm_user_assigned_identity.azurerm_user_assigned_identity.id
}

output "azurerm_user_assigned_identity_client_id" {
  description = "The client ID of the Managed Identity."
  value       = azurerm_user_assigned_identity.azurerm_user_assigned_identity.client_id
}

output "azurerm_user_assigned_identity_principal_id" {
  description = "The principal ID of the Managed Identity."
  value       = azurerm_user_assigned_identity.azurerm_user_assigned_identity.principal_id
}