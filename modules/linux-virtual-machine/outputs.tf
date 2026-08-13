# Outputs for the Azure Linux Virtual Machine module
output "linux_virtual_machine_id" {
  description = "The ID of the Linux virtual machine."
  value       = azurerm_linux_virtual_machine.azurerm_linux_virtual_machine.id
}

output "linux_virtual_machine_name" {
  description = "The name of the Linux virtual machine."
  value       = azurerm_linux_virtual_machine.azurerm_linux_virtual_machine.name
}

output "linux_virtual_machine_resource_group_name" {
  description = "The name of the resource group in which the Linux virtual machine is created."
  value       = azurerm_linux_virtual_machine.azurerm_linux_virtual_machine.resource_group_name
}

output "linux_virtual_machine_location" {
  description = "The location/region where the Linux virtual machine is created."
  value       = azurerm_linux_virtual_machine.azurerm_linux_virtual_machine.location
}

output "linux_virtual_machine_os_disk_id" {
  description = "The ID of the OS disk attached to the Linux virtual machine."
  value       = azurerm_linux_virtual_machine.azurerm_linux_virtual_machine.os_managed_disk_id
}