output "application_gateway_id" {
  description = "The ID of the Application Gateway."
  value       = azurerm_application_gateway.azurerm_application_gateway.id
}

output "application_gateway_name" {
  description = "The name of the Application Gateway."
  value       = azurerm_application_gateway.azurerm_application_gateway.name
}

output "application_gateway_public_ip_address" {
  description = "The public IP address of the Application Gateway."
  value       = azurerm_public_ip.azurerm_public_ip.ip_address
}

output "application_gateway_public_ip_id" {
  description = "The public IP address resource ID of the Application Gateway."
  value       = azurerm_public_ip.azurerm_public_ip.id
}

output "application_gateway_private_ip_address" {
  description = "The private frontend IP address of the Application Gateway."
  value       = one([for frontend in azurerm_application_gateway.azurerm_application_gateway.frontend_ip_configuration : frontend.private_ip_address if frontend.name == "private-frontend-ip"])
}

output "application_gateway_identity_principal_id" {
  description = "The principal ID of the Application Gateway user-assigned identity."
  value       = azurerm_user_assigned_identity.azurerm_user_assigned_identity.principal_id
}

output "application_gateway_user_assigned_identity_id" {
  description = "The resource ID of the Application Gateway user-assigned identity."
  value       = azurerm_user_assigned_identity.azurerm_user_assigned_identity.id
}

output "application_gateway_backend_address_pool_id" {
  description = "The ID of the default backend address pool."
  value       = one([for pool in azurerm_application_gateway.azurerm_application_gateway.backend_address_pool : pool.id if pool.name == "default-backend-pool"])
}
