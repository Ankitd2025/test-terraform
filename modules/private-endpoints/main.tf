resource "azurerm_private_endpoint" "azurerm_private_endpoint" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  private_service_connection {
    name                           = "${var.name}-psc"
    is_manual_connection           = false
    private_connection_resource_id = var.private_connection_resource_id
    subresource_names              = var.subresource_names
  }
  private_dns_zone_group {
    name                 = "${var.name}-pdzg"
    private_dns_zone_ids = var.private_dns_zone_ids
  }
  tags = var.tags
}