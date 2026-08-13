resource "azurerm_linux_virtual_machine" "azurerm_linux_virtual_machine" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.azurerm_network_interface.id,
  ]
  os_disk {
    caching                = var.os_disk_caching
    storage_account_type   = var.os_disk_storage_account_type
    disk_size_gb           = var.os_disk_size_gb
  }
  source_image_reference {
    publisher = var.source_image_publisher
    offer     = var.source_image_offer
    sku       = var.source_image_sku
    version   = var.source_image_version
  }
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }
  identity { type = "SystemAssigned" }

  tags = var.tags

  depends_on = [
    azurerm_network_interface.azurerm_network_interface
  ]
}

resource "azurerm_network_interface_security_group_association" "azurerm_network_interface_security_group_association" {
  network_interface_id      = azurerm_network_interface.azurerm_network_interface.id
  network_security_group_id = azurerm_network_security_group.azurerm_network_security_group.id
}