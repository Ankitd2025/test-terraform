resource "azurerm_resource_group" "azurerm_resource_group" {
  name     = var.name
  location = var.location
  tags     = var.tags
}

