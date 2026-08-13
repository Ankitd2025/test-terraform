resource "azurerm_virtual_network" "azurerm_virtual_network" {
  name                = var.name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}