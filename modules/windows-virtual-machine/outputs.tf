output "windows_virtual_machine_id" {
  description = "The ID of the Windows virtual machine."
  value       = azurerm_windows_virtual_machine.azurerm_windows_virtual_machine.id
}

output "windows_virtual_machine_name" {
  description = "The name of the Windows virtual machine."
  value       = azurerm_windows_virtual_machine.azurerm_windows_virtual_machine.name
}

output "windows_virtual_machine_private_ip_address" {
  description = "The private IP address of the Windows virtual machine."
  value       = azurerm_network_interface.azurerm_network_interface.private_ip_address
}

output "windows_virtual_machine_identity_principal_id" {
  description = "The principal ID of the Windows virtual machine system-assigned identity."
  value       = azurerm_windows_virtual_machine.azurerm_windows_virtual_machine.identity[0].principal_id
}

output "windows_virtual_machine_network_interface_id" {
  description = "The ID of the Windows virtual machine network interface."
  value       = azurerm_network_interface.azurerm_network_interface.id
}
