# Outputs for the Disk Encryption Set module
output "disk_encryption_set_id" {
  description = "The ID of the Disk Encryption Set."
  value       = azurerm_disk_encryption_set.azurerm_disk_encryption_set.id
}

output "disk_encryption_set_name" {
  description = "The name of the Disk Encryption Set."
  value       = azurerm_disk_encryption_set.azurerm_disk_encryption_set.name
}

output "disk_encryption_set_identity_principal_id" {
  description = "The principal ID of the managed identity assigned to the Disk Encryption Set."
  value       = azurerm_disk_encryption_set.azurerm_disk_encryption_set.identity[0].principal_id
}