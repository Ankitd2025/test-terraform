resource "azurerm_kubernetes_cluster" "azurerm_kubernetes_cluster" {
  name                              = var.name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  dns_prefix                        = var.dns_prefix
  kubernetes_version                = var.kubernetes_version
  sku_tier                          = var.sku_tier
  private_cluster_enabled           = var.private_cluster_enabled
  private_dns_zone_id               = var.private_dns_zone_id
  local_account_disabled            = var.local_account_disabled
  role_based_access_control_enabled = true
  azure_policy_enabled              = var.azure_policy_enabled
  oidc_issuer_enabled               = var.oidc_issuer_enabled
  workload_identity_enabled         = var.workload_identity_enabled
  image_cleaner_enabled             = var.image_cleaner_enabled
  image_cleaner_interval_hours      = var.image_cleaner_interval_hours
  automatic_upgrade_channel         = var.automatic_upgrade_channel
  node_os_upgrade_channel           = var.node_os_upgrade_channel
  tags                              = var.tags

  default_node_pool {
    name                         = var.default_node_pool_name
    vm_size                      = var.default_node_pool_vm_size
    vnet_subnet_id               = var.vnet_subnet_id
    auto_scaling_enabled         = var.default_node_pool_auto_scaling_enabled
    node_count                   = var.default_node_pool_auto_scaling_enabled ? null : var.default_node_pool_node_count
    min_count                    = var.default_node_pool_auto_scaling_enabled ? var.default_node_pool_min_count : null
    max_count                    = var.default_node_pool_auto_scaling_enabled ? var.default_node_pool_max_count : null
    zones                        = var.default_node_pool_zones
    os_disk_size_gb              = var.default_node_pool_os_disk_size_gb
    os_disk_type                 = var.default_node_pool_os_disk_type
    os_sku                       = var.default_node_pool_os_sku
    node_public_ip_enabled       = false
    # only_critical_addons_enabled = var.default_node_pool_only_critical_addons_enabled
    # host_encryption_enabled      = var.default_node_pool_host_encryption_enabled
    # fips_enabled                 = var.default_node_pool_fips_enabled

    upgrade_settings {
      max_surge = var.default_node_pool_max_surge
    }
  }

  identity {
    type         = var.identity_type
    identity_ids = var.identity_type == "UserAssigned" ? var.identity_ids : null
  }

  network_profile {
    network_plugin      = var.network_plugin
    network_plugin_mode = var.network_plugin_mode
    network_policy      = var.network_policy
    network_data_plane  = var.network_data_plane
    load_balancer_sku   = "standard"
    outbound_type       = var.outbound_type
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
  }

  azure_active_directory_role_based_access_control {
    tenant_id              = var.tenant_id
    admin_group_object_ids = var.admin_group_object_ids
    azure_rbac_enabled     = var.azure_rbac_enabled
  }

  dynamic "api_server_access_profile" {
    for_each = length(var.api_server_authorized_ip_ranges) > 0 ? [1] : []

    content {
      authorized_ip_ranges = var.api_server_authorized_ip_ranges
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider_enabled ? [1] : []

    content {
      secret_rotation_enabled  = var.key_vault_secret_rotation_enabled
      secret_rotation_interval = var.key_vault_secret_rotation_interval
    }
  }

  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id == null ? [] : [1]

    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  dynamic "microsoft_defender" {
    for_each = var.microsoft_defender_enabled && var.log_analytics_workspace_id != null ? [1] : []

    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  dynamic "monitor_metrics" {
    for_each = var.monitor_metrics_enabled ? [1] : []

    content {
      annotations_allowed = var.monitor_metrics_annotations_allowed
      labels_allowed      = var.monitor_metrics_labels_allowed
    }
  }

  lifecycle {
    precondition {
      condition     = var.private_cluster_enabled
      error_message = "PCI-aligned AKS deployments must keep private_cluster_enabled set to true."
    }

    precondition {
      condition     = var.local_account_disabled
      error_message = "PCI-aligned AKS deployments must disable local cluster admin accounts."
    }

    precondition {
      condition     = var.azure_policy_enabled
      error_message = "PCI-aligned AKS deployments must enable Azure Policy."
    }

    precondition {
      condition     = var.azure_rbac_enabled
      error_message = "PCI-aligned AKS deployments must use Azure RBAC."
    }

    precondition {
      condition     = var.default_node_pool_auto_scaling_enabled ? var.default_node_pool_min_count <= var.default_node_pool_max_count : true
      error_message = "default_node_pool_min_count must be less than or equal to default_node_pool_max_count."
    }
  }
}
