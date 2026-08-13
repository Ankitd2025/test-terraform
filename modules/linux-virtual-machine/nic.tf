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
