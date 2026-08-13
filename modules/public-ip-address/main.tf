resource "azurerm_public_ip" "azurerm_public_ip" {
  name                 = var.name
  location             = var.location
  resource_group_name  = var.resource_group_name
  allocation_method    = var.allocation_method
  sku                  = var.sku
  zones                = var.zones
  ddos_protection_mode = var.ddos_protection_mode
  tags                 = var.tags
}
