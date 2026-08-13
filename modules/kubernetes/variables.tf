# Variables for the PCI-aligned Azure Kubernetes Service module
variable "name" {
  description = "The name of the AKS cluster."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the AKS cluster."
  type        = string
}

variable "location" {
  description = "The Azure region where the AKS cluster will be created."
  type        = string
}

variable "dns_prefix" {
  description = "The DNS prefix to use with the AKS cluster."
  type        = string
}

variable "tenant_id" {
  description = "The Microsoft Entra tenant ID used for AKS Azure RBAC."
  type        = string
}

variable "admin_group_object_ids" {
  description = "Microsoft Entra group object IDs that should have AKS cluster administrator access."
  type        = list(string)
}

variable "vnet_subnet_id" {
  description = "The subnet ID where AKS nodes will be deployed."
  type        = string
}

variable "kubernetes_version" {
  description = "The AKS Kubernetes version. Leave null to use the Azure default."
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "The AKS SKU tier. Use Standard for production workloads that need the AKS uptime SLA."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "The sku_tier value must be Free, Standard, or Premium."
  }
}

variable "private_cluster_enabled" {
  description = "Whether the AKS API server is private. PCI-aligned deployments should keep this true."
  type        = bool
  default     = true
}

variable "private_dns_zone_id" {
  description = "The private DNS zone ID for the private AKS API server. Use null for system-managed private DNS."
  type        = string
  default     = null
}

variable "local_account_disabled" {
  description = "Whether local AKS admin accounts are disabled. PCI-aligned deployments should keep this true."
  type        = bool
  default     = true
}

variable "azure_policy_enabled" {
  description = "Whether Azure Policy for AKS is enabled. PCI-aligned deployments should keep this true."
  type        = bool
  default     = true
}

variable "azure_rbac_enabled" {
  description = "Whether Azure RBAC authorization is enabled for AKS. PCI-aligned deployments should keep this true."
  type        = bool
  default     = true
}

variable "oidc_issuer_enabled" {
  description = "Whether the OIDC issuer is enabled for workload identity."
  type        = bool
  default     = true
}

variable "workload_identity_enabled" {
  description = "Whether Microsoft Entra Workload ID is enabled."
  type        = bool
  default     = true
}

variable "image_cleaner_enabled" {
  description = "Whether AKS image cleaner is enabled."
  type        = bool
  default     = true
}

variable "image_cleaner_interval_hours" {
  description = "The interval in hours for AKS image cleaner."
  type        = number
  default     = 48
}

variable "automatic_upgrade_channel" {
  description = "The automatic AKS upgrade channel."
  type        = string
  default     = "patch"

  validation {
    condition     = contains(["patch", "rapid", "stable", "node-image", "none"], var.automatic_upgrade_channel)
    error_message = "The automatic_upgrade_channel value must be patch, rapid, stable, node-image, or none."
  }
}

variable "node_os_upgrade_channel" {
  description = "The node OS upgrade channel."
  type        = string
  default     = "SecurityPatch"

  validation {
    condition     = contains(["Unmanaged", "SecurityPatch", "NodeImage", "None"], var.node_os_upgrade_channel)
    error_message = "The node_os_upgrade_channel value must be Unmanaged, SecurityPatch, NodeImage, or None."
  }
}

variable "default_node_pool_name" {
  description = "The name of the default AKS node pool."
  type        = string
  default     = "system"
}

variable "default_node_pool_vm_size" {
  description = "The VM size for the default AKS node pool."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "default_node_pool_auto_scaling_enabled" {
  description = "Whether cluster autoscaler is enabled for the default node pool."
  type        = bool
  default     = true
}

variable "default_node_pool_node_count" {
  description = "The fixed node count when autoscaling is disabled."
  type        = number
  default     = 3
}

variable "default_node_pool_min_count" {
  description = "The minimum node count when autoscaling is enabled."
  type        = number
  default     = 3
}

variable "default_node_pool_max_count" {
  description = "The maximum node count when autoscaling is enabled."
  type        = number
  default     = 6
}

variable "default_node_pool_zones" {
  description = "The availability zones for the default node pool."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "default_node_pool_os_disk_size_gb" {
  description = "The OS disk size in GB for default node pool nodes."
  type        = number
  default     = 128
}

variable "default_node_pool_os_disk_type" {
  description = "The OS disk type for default node pool nodes."
  type        = string
  default     = "Managed"

  validation {
    condition     = contains(["Ephemeral", "Managed"], var.default_node_pool_os_disk_type)
    error_message = "The default_node_pool_os_disk_type value must be Ephemeral or Managed."
  }
}

variable "default_node_pool_os_sku" {
  description = "The OS SKU for default node pool nodes."
  type        = string
  default     = "Ubuntu"

  validation {
    condition     = contains(["AzureLinux", "Ubuntu", "Windows2019", "Windows2022"], var.default_node_pool_os_sku)
    error_message = "The default_node_pool_os_sku value must be AzureLinux, Ubuntu, Windows2019, or Windows2022."
  }
}

variable "default_node_pool_only_critical_addons_enabled" {
  description = "Whether only critical add-ons can run on the default system node pool."
  type        = bool
  default     = true
}

variable "default_node_pool_host_encryption_enabled" {
  description = "Whether host encryption is enabled on the default node pool. Requires Azure feature registration."
  type        = bool
  default     = false
}

variable "default_node_pool_fips_enabled" {
  description = "Whether FIPS mode is enabled on the default node pool. Requires supported VM sizes and OS images."
  type        = bool
  default     = false
}

variable "default_node_pool_max_surge" {
  description = "The maximum surge value for default node pool upgrades."
  type        = string
  default     = "10%"
}

variable "identity_type" {
  description = "The managed identity type for the AKS cluster."
  type        = string
  default     = "SystemAssigned"

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned"], var.identity_type)
    error_message = "The identity_type value must be SystemAssigned or UserAssigned."
  }
}

variable "identity_ids" {
  description = "User-assigned managed identity IDs. Required when identity_type is UserAssigned."
  type        = list(string)
  default     = []
}

variable "network_plugin" {
  description = "The Kubernetes network plugin."
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "kubenet"], var.network_plugin)
    error_message = "The network_plugin value must be azure or kubenet."
  }
}

variable "network_plugin_mode" {
  description = "The network plugin mode. Use overlay with Azure CNI Overlay, or null for standard Azure CNI."
  type        = string
  default     = null

  validation {
    condition     = var.network_plugin_mode == null || contains(["overlay"], var.network_plugin_mode)
    error_message = "The network_plugin_mode value must be overlay or null."
  }
}

variable "network_policy" {
  description = "The Kubernetes network policy provider."
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "calico", "cilium"], var.network_policy)
    error_message = "The network_policy value must be azure, calico, or cilium."
  }
}

variable "network_data_plane" {
  description = "The network data plane used by AKS. Set to cilium when network_policy is cilium."
  type        = string
  default     = null

  validation {
    condition     = var.network_data_plane == null || contains(["azure", "cilium"], var.network_data_plane)
    error_message = "The network_data_plane value must be azure, cilium, or null."
  }
}

variable "outbound_type" {
  description = "The AKS outbound routing type. Use userDefinedRouting when egress must pass through Azure Firewall."
  type        = string
  default     = "loadBalancer"

  validation {
    condition     = contains(["loadBalancer", "managedNATGateway", "userAssignedNATGateway", "userDefinedRouting"], var.outbound_type)
    error_message = "The outbound_type value must be loadBalancer, managedNATGateway, userAssignedNATGateway, or userDefinedRouting."
  }
}

variable "service_cidr" {
  description = "The Kubernetes service CIDR."
  type        = string
  default     = "10.240.0.0/16"
}

variable "dns_service_ip" {
  description = "The Kubernetes DNS service IP address."
  type        = string
  default     = "10.240.0.10"
}

variable "api_server_authorized_ip_ranges" {
  description = "Optional authorized IP ranges for the API server when using public API access. Private PCI deployments normally leave this empty."
  type        = list(string)
  default     = []
}

variable "key_vault_secrets_provider_enabled" {
  description = "Whether the Azure Key Vault Secrets Provider add-on is enabled."
  type        = bool
  default     = true
}

variable "key_vault_secret_rotation_enabled" {
  description = "Whether Key Vault secret rotation is enabled."
  type        = bool
  default     = true
}

variable "key_vault_secret_rotation_interval" {
  description = "The Key Vault secret rotation interval."
  type        = string
  default     = "2m"
}

variable "microsoft_defender_enabled" {
  description = "Whether Microsoft Defender for Containers profile is enabled for AKS. Requires log_analytics_workspace_id."
  type        = bool
  default     = true
}

variable "monitor_metrics_enabled" {
  description = "Whether to enable the AKS Managed Prometheus metrics add-on."
  type        = bool
  default     = false
}

variable "monitor_metrics_annotations_allowed" {
  description = "Comma-separated Kubernetes annotation keys allowed on Managed Prometheus resource labels. Set null when no custom annotations are needed."
  type        = string
  default     = null
}

variable "monitor_metrics_labels_allowed" {
  description = "Comma-separated Kubernetes label keys allowed on Managed Prometheus resource labels. Set null when no custom labels are needed."
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "The resource ID of the Log Analytics workspace for AKS monitoring, Defender, and diagnostics."
  type        = string
  default     = null
}

variable "enable_diagnostic" {
  description = "Whether to enable diagnostic settings for the AKS cluster."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the AKS cluster."
  type        = map(string)
  default     = {}
}
