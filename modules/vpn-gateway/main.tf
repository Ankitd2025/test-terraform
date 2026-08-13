resource "azurerm_virtual_network_gateway" "azurerm_virtual_network_gateway" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  type                = var.type
  vpn_type            = var.vpn_type
  active_active       = var.active_active
  sku                 = var.sku
  tags                = var.tags
  bgp_enabled         = var.bgp_enabled
  ip_configuration {
    name                          = var.ip_configuration_name
    public_ip_address_id          = var.public_ip_address_id
    private_ip_address_allocation = var.private_ip_address_allocation
    subnet_id                     = var.subnet_id
  }
}
