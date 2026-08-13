resource "azurerm_network_interface" "azurerm_network_interface" {
  name                = lower("nic-${var.name}")
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = lower("ipconfig-${var.name}")
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_allocation_method
    private_ip_address            = var.private_ip_allocation_method == "Static" ? var.private_ip_address : null
    public_ip_address_id          = var.allow_public_access ? var.public_ip_address_id : null
  }

  tags = var.tags
}

resource "azurerm_network_security_group" "azurerm_network_security_group" {
  name                = lower("nsg-${var.name}")
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "allowed_inbound" {
  for_each                    = var.allowed_inbound_rules
  name                        = each.key
  priority                    = each.value.priority
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = each.value.protocol
  source_port_range           = "*"
  destination_port_ranges     = each.value.destination_port_ranges
  source_address_prefixes     = each.value.source_address_prefixes
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.azurerm_network_security_group.name
}

resource "azurerm_network_security_rule" "deny_vnet_inbound" {
  name                        = "Deny-VNet-Inbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.azurerm_network_security_group.name
}

resource "azurerm_network_interface_security_group_association" "azurerm_network_interface_security_group_association" {
  network_interface_id      = azurerm_network_interface.azurerm_network_interface.id
  network_security_group_id = azurerm_network_security_group.azurerm_network_security_group.id
}

resource "azurerm_windows_virtual_machine" "azurerm_windows_virtual_machine" {
  name                       = var.name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  size                       = var.size
  admin_username             = var.admin_username
  admin_password             = var.admin_password
  computer_name              = "WindowsVM"
  encryption_at_host_enabled = var.encryption_at_host_enabled
  secure_boot_enabled        = var.secure_boot_enabled
  vtpm_enabled               = var.vtpm_enabled
  provision_vm_agent         = true
  automatic_updates_enabled  = true
  patch_mode                 = var.patch_mode

  network_interface_ids = [
    azurerm_network_interface.azurerm_network_interface.id,
  ]

  os_disk {
    caching                = var.os_disk_caching
    storage_account_type   = var.os_disk_storage_account_type
    disk_encryption_set_id = var.enable_disk_encryption ? var.disk_encryption_set_id : null
    disk_size_gb           = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.source_image_publisher
    offer     = var.source_image_offer
    sku       = var.source_image_sku
    version   = var.source_image_version
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  depends_on = [
    azurerm_network_interface_security_group_association.azurerm_network_interface_security_group_association
  ]
}

resource "azurerm_virtual_machine_extension" "azure_monitor_windows_agent" {
  count                      = var.enable_monitoring_extension ? 1 : 0
  name                       = "${var.name}-ama"
  virtual_machine_id         = azurerm_windows_virtual_machine.azurerm_windows_virtual_machine.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  tags                       = merge(var.tags, { EXTENSION = "MONITORING" })
}

resource "azurerm_virtual_machine_extension" "guest_configuration" {
  count                      = var.enable_guest_configuration ? 1 : 0
  name                       = "${var.name}-guest-config"
  virtual_machine_id         = azurerm_windows_virtual_machine.azurerm_windows_virtual_machine.id
  publisher                  = "Microsoft.GuestConfiguration"
  type                       = "ConfigurationforWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  tags                       = merge(var.tags, { EXTENSION = "GUEST_CONFIGURATION" })
}
