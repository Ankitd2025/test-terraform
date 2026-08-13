resource "azurerm_kubernetes_cluster_node_pool" "azurerm_kubernetes_cluster_node_pool" {
	name                         = var.name
	kubernetes_cluster_id        = var.kubernetes_cluster_id
	vm_size                      = var.vm_size
	vnet_subnet_id               = var.vnet_subnet_id
	mode                         = "User"
	orchestrator_version         = var.orchestrator_version
	auto_scaling_enabled         = var.auto_scaling_enabled
	node_count                   = var.auto_scaling_enabled ? null : var.node_count
	min_count                    = var.auto_scaling_enabled ? var.min_count : null
	max_count                    = var.auto_scaling_enabled ? var.max_count : null
	zones                        = var.zones
	os_type                      = var.os_type
	os_sku                       = var.os_sku
	os_disk_size_gb              = var.os_disk_size_gb
	os_disk_type                 = var.os_disk_type
	node_public_ip_enabled       = false
	# host_encryption_enabled      = var.host_encryption_enabled
	# fips_enabled                 = var.fips_enabled
	max_pods                     = var.max_pods
	node_labels                  = var.node_labels
	node_taints                  = var.node_taints
	temporary_name_for_rotation  = var.temporary_name_for_rotation
	scale_down_mode              = var.scale_down_mode
	tags                         = var.tags

	upgrade_settings {
		max_surge = var.max_surge
	}

	lifecycle {
		precondition {
			condition     = var.auto_scaling_enabled ? var.min_count <= var.max_count : true
			error_message = "min_count must be less than or equal to max_count."
		}
	}
}
