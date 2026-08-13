resource "azurerm_bastion_host" "azurerm_bastion_host" {
  name                   = var.name
  resource_group_name    = var.resource_group_name
  location               = var.location
  sku                    = var.sku
  copy_paste_enabled     = var.copy_paste_enabled
  file_copy_enabled      = var.file_copy_enabled
  ip_connect_enabled     = var.ip_connect_enabled
  shareable_link_enabled = var.shareable_link_enabled
  tunneling_enabled      = var.tunneling_enabled
  tags                   = var.tags
  ip_configuration {
    name                 = "${var.name}-ipconfig"
    subnet_id            = var.subnet_id
    public_ip_address_id = var.public_ip_address_id
  }
}
