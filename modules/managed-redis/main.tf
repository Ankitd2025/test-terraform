resource "azurerm_managed_redis" "azurerm_managed_redis" {
  name                      = var.name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  sku_name                  = var.sku_name
  high_availability_enabled = var.high_availability_enabled
  public_network_access     = var.public_network_access
  tags                      = var.tags

  default_database {
    access_keys_authentication_enabled = var.access_keys_authentication_enabled
    client_protocol                    = var.client_protocol
    clustering_policy                  = var.clustering_policy
    eviction_policy                    = var.eviction_policy
  }

  identity {
    type = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  customer_managed_key {
    key_vault_key_id          = var.key_vault_key_id
    user_assigned_identity_id = var.user_assigned_identity_id
  }
}

