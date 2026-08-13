resource "azurerm_container_registry" "azurerm_container_registry" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  quarantine_policy_enabled     = var.quarantine_policy_enabled
  zone_redundancy_enabled       = var.zone_redundancy_enabled
  anonymous_pull_enabled        = var.anonymous_pull_enabled
  data_endpoint_enabled         = var.data_endpoint_enabled
  tags                          = var.tags

  dynamic "georeplications" {
    for_each = var.geo_replications

    content {
      location                  = georeplications.value.location
      regional_endpoint_enabled = georeplications.value.regional_endpoint_enabled
      zone_redundancy_enabled   = georeplications.value.zone_redundancy_enabled
      tags                      = var.tags
    }
  }

  lifecycle {
    precondition {
      condition     = length(var.geo_replications) == 0 || var.sku == "Premium"
      error_message = "Container Registry geo-replication requires the Premium SKU."
    }

    precondition {
      condition     = !var.quarantine_policy_enabled || var.sku == "Premium"
      error_message = "Container Registry quarantine policy requires the Premium SKU."
    }

    precondition {
      condition     = !var.zone_redundancy_enabled || var.sku == "Premium"
      error_message = "Container Registry zone redundancy requires the Premium SKU."
    }

    precondition {
      condition     = !var.data_endpoint_enabled || var.sku == "Premium"
      error_message = "Container Registry dedicated data endpoints require the Premium SKU."
    }
  }
}
