resource "azurerm_subnet" "azurerm_subnet" {
  name                              = var.name
  resource_group_name               = var.resource_group_name
  virtual_network_name              = var.virtual_network_name
  address_prefixes                  = var.address_prefixes
  private_endpoint_network_policies = var.private_endpoint_network_policies
  dynamic "delegation" {
    for_each = var.delegation_name != null ? [1] : []
    content {
      name = var.delegation_name
      service_delegation {
        name    = var.delegation_service_name
        actions = var.delegation_actions
      }
    }
  }
}

resource "azurerm_network_security_group" "azurerm_network_security_group" {
  count               = var.create_nsg ? 1 : 0
  name                = lower("nsg-${var.name}")
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "azurerm_subnet_network_security_group_association" {
  count                     = var.create_nsg ? 1 : 0
  subnet_id                 = azurerm_subnet.azurerm_subnet.id
  network_security_group_id = azurerm_network_security_group.azurerm_network_security_group[0].id
}
