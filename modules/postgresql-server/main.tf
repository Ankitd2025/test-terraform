resource "azurerm_postgresql_flexible_server" "postgresql_flexible_server" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  version                       = var.server_version
  delegated_subnet_id           = var.delegated_subnet_id
  private_dns_zone_id           = var.private_dns_zone_id
  public_network_access_enabled = var.public_network_access_enabled
  administrator_login           = var.administrator_login
  administrator_password        = var.administrator_password
  zone                          = var.zone
  storage_mb                    = var.storage_mb
  storage_tier                  = var.storage_tier
  sku_name                      = var.sku_name
  tags                          = var.tags

  dynamic "high_availability" {
    for_each = var.high_availability_mode != "" ? [var.high_availability_mode] : []
    content {
      mode = high_availability.value
    }
  }
}

resource "azurerm_postgresql_flexible_server_database" "postgresql_flexible_server_database" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
  collation = var.database_collation
  charset   = var.database_charset
}
