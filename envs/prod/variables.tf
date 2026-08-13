# Subscription and Provider Configuration for the Hub Environment
variable "hub_subscription_id" {
  description = "The Azure subscription ID for the Hub environment."
  type        = string
}

variable "hub_resource_group_name" {
  description = "The name of the resource group for the Hub environment."
  type        = string
}

variable "hub_vnet_name" {
  description = "The name of the Virtual Network for the Hub environment."
  type        = string
}

variable "hub_firewall_name" {
  description = "The name of the Azure Firewall in the Hub environment used as the AKS UDR next hop."
  type        = string
}

variable "hub_bastion_subnet_name" {
  description = "The name of the Azure Bastion subnet in the Hub virtual network."
  type        = string
  default     = "AzureBastionSubnet"
}

# End of subscription and provider configuration for the Hub environment

# Subscription and Provider Configuration for the Spoke Environment
variable "subscription_id" {
  description = "The Azure subscription ID to deploy resources into."
  type        = string
}
# End of subscription and provider configuration for the Spoke environment

# Local Configuration for the Spoke Environment
variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "env" {
  description = "The environment (e.g., dev, test, prod)."
  type        = string
}

variable "region_code" {
  description = "The region code (e.g., us, eu, ap)."
  type        = string
}

variable "region" {
  description = "The Azure region (e.g., eastus, westeurope)."
  type        = string
}

variable "instance" {
  description = "The instance identifier (e.g., 01, 02)."
  type        = string
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
# End of local configuration for the Spoke environment


# Varibales for the Virtual Network in the Spoke environment
variable "address_space" {
  description = "The address space for the Virtual Network."
  type        = list(string)
}
# End of variables for the Virtual Network in the Spoke environment

# Variables for Azure Subnet module
variable "subnets" {
  description = "A map of subnets to create within the Virtual Network"
  type = map(object({
    subnet_name                       = string
    address_prefixes                  = list(string)
    create_nsg                        = optional(bool, false)
    service_endpoints                 = optional(list(string))
    private_endpoint_network_policies = optional(string)
    delegation_name                   = optional(string)
    delegation_service_name           = optional(string)
    delegation_actions                = optional(list(string))
  }))
}
# End of variables for Azure Subnet module

# Variables for Azure Key Vault module
variable "kv_suffix" {
  description = "The suffix to use for the Key Vault name."
  type        = string
} 
# End of variables for Azure Key Vault module

# Variables for the Azure Key Vault Secret Management with Customer-Managed Keys (CMK) module
variable "key_type" {
  description = "The type of the key to be created in Azure Key Vault (e.g., RSA, EC)."
  type        = string
}

variable "key_size" {
  description = "The size of the key to be created in Azure Key Vault (e.g., 2048, 3072, 4096 for RSA)."
  type        = number
}

variable "key_opts" {
  description = "A list of operations that the key can perform (e.g., encrypt, decrypt, sign, verify)."
  type        = list(string)
}

variable "notify_before_expiry" {
  description = "The time before the key expires when a notification will be sent (e.g., 'P7D' for 7 days)."
  type        = string
}

variable "time_after_creation" {
  description = "The time after the key is created when the rotation policy will trigger (e.g., 'P30D' for 30 days)."
  type        = string
}

variable "expire_after" {
  description = "The duration after which the key will expire (e.g., 'P365D' for 365 days)."
  type        = string
}
# End of variables for the Azure Key Vault Secret Management with Customer-Managed Keys (CMK) module


# Variables for Azure Storage Account module
variable "stg_blob_suffix" {
  description = "The suffix to use for the Storage Account name."
  type        = string
}
# End of variables for Azure Storage Account module

# Variables for the Azure Container Registry module
variable "acr_sku" {
  description = "The SKU of the Azure Container Registry."
  type        = string
}

variable "acr_geo_replications" {
  description = "Optional geo-replication locations for the Container Registry. Leave empty to create no geo-replications. Geo-replication requires the Premium SKU."
  type = list(object({
    location                  = string
    regional_endpoint_enabled = optional(bool, true)
    zone_redundancy_enabled   = optional(bool, false)
    tags                      = optional(map(string), null)
  }))
  default = []
}
# End of variables for the Azure Container Registry module


# Variables for the Azure Application Gateway module
variable "application_gateway_sku_name" {
  description = "The Application Gateway SKU name. Use WAF_v2 for WAF-enabled deployments."
  type        = string
  default     = "WAF_v2"
}

variable "application_gateway_key_vault_certificate_secret_id" {
  description = "The Key Vault certificate secret ID for Application Gateway HTTPS listeners. Leave null to use HTTP listeners only while RBAC is still configured."
  type        = string
  default     = null
}
# End of variables for the Azure Application Gateway module


# Variables for the Azure Kubernetes Service module
variable "aks_admin_group_object_ids" {
  description = "Microsoft Entra group object IDs that should have AKS cluster administrator access."
  type        = list(string)
}

variable "aks_kubernetes_version" {
  description = "The AKS Kubernetes version. Leave null to use the Azure default."
  type        = string
  default     = null
}

variable "aks_sku_tier" {
  description = "The AKS SKU tier. Use Standard for production workloads that need the AKS uptime SLA."
  type        = string
  default     = "Standard"
}

variable "aks_system_node_pool_vm_size" {
  description = "The VM size for the AKS system node pool."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "aks_system_node_pool_min_count" {
  description = "The minimum node count for the AKS system node pool."
  type        = number
  default     = 3
}

variable "aks_system_node_pool_max_count" {
  description = "The maximum node count for the AKS system node pool."
  type        = number
  default     = 6
}

variable "aks_system_node_pool_zones" {
  description = "The availability zones for the AKS system node pool."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "aks_system_node_pool_os_disk_size_gb" {
  description = "The OS disk size in GB for AKS system node pool nodes."
  type        = number
  default     = 128
}

variable "aks_network_plugin_mode" {
  description = "The AKS network plugin mode. Use overlay with Azure CNI Overlay, or null for standard Azure CNI."
  type        = string
  default     = "overlay"
}

variable "aks_network_policy" {
  description = "The Kubernetes network policy provider for AKS."
  type        = string
  default     = "azure"
}

variable "aks_network_data_plane" {
  description = "The AKS network data plane. Set to cilium when aks_network_policy is cilium."
  type        = string
  default     = null
}

variable "aks_outbound_type" {
  description = "The AKS outbound routing type. Use userDefinedRouting when egress is forced through the hub firewall."
  type        = string
  default     = "userDefinedRouting"
}

variable "aks_service_cidr" {
  description = "The Kubernetes service CIDR for AKS."
  type        = string
  default     = "10.240.0.0/16"
}

variable "aks_dns_service_ip" {
  description = "The Kubernetes DNS service IP address for AKS."
  type        = string
  default     = "10.240.0.10"
}

variable "aks_monitor_metrics_enabled" {
  description = "Whether to enable the AKS Managed Prometheus metrics add-on."
  type        = bool
  default     = true
}

variable "aks_monitor_metrics_annotations_allowed" {
  description = "Comma-separated Kubernetes annotation keys allowed on Managed Prometheus resource labels. Set null when no custom annotations are needed."
  type        = string
  default     = null
}

variable "aks_monitor_metrics_labels_allowed" {
  description = "Comma-separated Kubernetes label keys allowed on Managed Prometheus resource labels. Set null when no custom labels are needed."
  type        = string
  default     = null
}
# End of variables for the Azure Kubernetes Service module

# Variables for the Azure Kubernetes Service user node pool module
variable "aks_user_node_pool_name" {
  description = "The name of the AKS user node pool."
  type        = string
  default     = "user"
}

variable "aks_user_node_pool_vm_size" {
  description = "The VM size for the AKS user node pool."
  type        = string
  default     = "Standard_D4as_v6"
}

variable "aks_user_node_pool_auto_scaling_enabled" {
  description = "Whether autoscaling is enabled for the AKS user node pool."
  type        = bool
  default     = true
}

variable "aks_user_node_pool_node_count" {
  description = "The fixed node count for the AKS user node pool when autoscaling is disabled."
  type        = number
  default     = 2
}

variable "aks_user_node_pool_min_count" {
  description = "The minimum node count for the AKS user node pool."
  type        = number
  default     = 2
}

variable "aks_user_node_pool_max_count" {
  description = "The maximum node count for the AKS user node pool."
  type        = number
  default     = 6
}

variable "aks_user_node_pool_zones" {
  description = "The availability zones for the AKS user node pool."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "aks_user_node_pool_os_sku" {
  description = "The OS SKU for the AKS user node pool."
  type        = string
  default     = "AzureLinux"
}

variable "aks_user_node_pool_os_disk_size_gb" {
  description = "The OS disk size in GB for AKS user node pool nodes."
  type        = number
  default     = 128
}

variable "aks_user_node_pool_max_pods" {
  description = "The maximum number of pods that can run on each AKS user node."
  type        = number
  default     = 30
}

variable "aks_user_node_pool_node_labels" {
  description = "A map of Kubernetes labels to apply to AKS user node pool nodes."
  type        = map(string)
  default     = {}
}

variable "aks_user_node_pool_node_taints" {
  description = "A list of Kubernetes taints to apply to AKS user node pool nodes."
  type        = list(string)
  default     = []
}

variable "aks_user_node_pool_temporary_name_for_rotation" {
  description = "The temporary node pool name used when Terraform must rotate the AKS user node pool for immutable property changes."
  type        = string
  default     = "tmpuser"
}
# End of variables for the Azure Kubernetes Service user node pool module


# Variables for the Multiple Kubernetes Namespace for the AKS Cluster
variable "kubernetes_namespaces" {
  description = "A list of Kubernetes namespaces to create in the AKS cluster."
  type = map(object({
    name = string
  }))
}
# End of variables for the Multiple Kubernetes Namespace for the AKS Cluster

# Variables for the Multiple Kubernetes Service Account for the AKS Cluster
variable "kubernetes_service_accounts" {
  description = "A list of Kubernetes service accounts to create in the AKS cluster."
  type = map(object({
    name      = string
    namespace = string
  }))
}
# End of variables for the Multiple Kubernetes Service Account for the AKS Cluster

# Variables for the Azure Virtual Network data source module to retrieve the Operations Virtual Network details
variable "ops_vnet_name" {
  description = "The name of the Operations Virtual Network."
  type        = string
}

variable "ops_resource_group_name" {
  description = "The name of the resource group in which the Operations Virtual Network is located."
  type        = string
}
# End of variables for the Azure Virtual Network data source module to retrieve the Operations Virtual Network details

# Variables for the Virtual Network Peering between the Operations and Spoke environments
variable "ops_allow_virtual_network_access" {
  description = "Whether to allow virtual network access between the Operations and Spoke environments."
  type        = bool
}

variable "ops_allow_forwarded_traffic" {
  description = "Whether to allow forwarded traffic from the Spoke environment to the Operations environment."
  type        = bool
}

variable "ops_allow_gateway_transit" {
  description = "Whether to allow gateway transit between the Operations and Spoke environments."
  type        = bool
}

variable "ops_use_remote_gateways" {
  description = "Whether to use remote gateways for the peering from the Operations environment to the Spoke environment."
  type        = bool
}
# End of variables for the Virtual Network Peering between the Operations and Spoke environments

# Variables for the Virtual Network Peering between the Hub and Spoke environments
variable "hub_allow_virtual_network_access" {
  description = "Whether to allow virtual network access between the Hub and Spoke environments."
  type        = bool
}

variable "hub_allow_forwarded_traffic" {
  description = "Whether to allow forwarded traffic from the Spoke environment to the Hub environment."
  type        = bool
}

variable "hub_allow_gateway_transit" {
  description = "Whether to allow gateway transit between the Hub and Spoke environments."
  type        = bool
}

variable "hub_use_remote_gateways" {
  description = "Whether to use remote gateways for the peering from the Hub environment to the Spoke environment."
  type        = bool
}
# End of variables for the Virtual Network Peering between the Hub and Spoke environments

# Variables for the Virtual Network Peering between the Spoke and Hub environments
variable "spoke_allow_virtual_network_access" {
  description = "Whether to allow virtual network access between the Spoke and Hub environments."
  type        = bool
}

variable "spoke_allow_forwarded_traffic" {
  description = "Whether to allow forwarded traffic from the Hub environment to the Spoke environment."
  type        = bool
}

variable "spoke_allow_gateway_transit" {
  description = "Whether to allow gateway transit between the Spoke and Hub environments."
  type        = bool
}

variable "spoke_use_remote_gateways" {
  description = "Whether to use remote gateways for the peering from the Spoke environment to the Hub environment."
  type        = bool
}
# End of variables for the Virtual Network Peering between the Spoke and Hub environments

variable "managed_redis_sku_name" {
  description = "The Azure Managed Redis SKU name."
  type        = string
  default     = "Enterprise_E5"
}

variable "managed_redis_high_availability_enabled" {
  description = "Whether high availability is enabled for each Azure Managed Redis instance."
  type        = bool
  default     = false
}

variable "managed_redis_public_network_access" {
  description = "Whether public network access is enabled for Azure Managed Redis."
  type        = string
  default     = "Disabled"
}

variable "managed_redis_access_keys_authentication_enabled" {
  description = "Whether access key authentication is enabled for Azure Managed Redis."
  type        = bool
  default     = true
}

variable "managed_redis_client_protocol" {
  description = "The client protocol for Azure Managed Redis."
  type        = string
  default     = "Encrypted"
}

variable "managed_redis_clustering_policy" {
  description = "The clustering policy for Azure Managed Redis."
  type        = string
  default     = "EnterpriseCluster"
}

variable "managed_redis_eviction_policy" {
  description = "The eviction policy for Azure Managed Redis."
  type        = string
  default     = "VolatileLRU"
}

variable "managed_redis_private_endpoint_subresource_names" {
  description = "The private endpoint subresource names for Azure Managed Redis."
  type        = list(string)
  default     = ["redis"]
}
# End of variables for Azure Managed Redis module

# Variables for the Azure Application Insights module
variable "application_insights_application_type" {
  description = "The application type of the Azure Application Insights instance."
  type        = string
}
variable "application_insights_daily_data_cap_in_gb" {
  description = "The daily data cap in GB for the Azure Application Insights instance."
  type        = number
  default     = 100
}
variable "application_insights_retention_in_days" {
  description = "The data retention period in days for the Azure Application Insights instance."
  type        = number
  default     = 90
}
variable "application_insights_sampling_percentage" {
  description = "The sampling percentage for the Azure Application Insights instance."
  type        = number
  default     = 100
}

variable "application_insights_internet_ingestion_enabled" {
  description = "Whether internet ingestion is enabled for the Azure Application Insights instance."
  type        = bool
  default     = false
}
variable "application_insights_internet_query_enabled" {
  description = "Whether internet query is enabled for the Azure Application Insights instance."
  type        = bool
  default     = false
}

#variables for the Azure PostgreSQL Flexible Server module
variable "postgresql_flexible_server_version" {
  description = "The version of the PostgreSQL Flexible Server."
  type        = string
}

variable "postgresql_flexible_server_public_network_access_enabled" {
  description = "Whether public network access is enabled for the PostgreSQL Flexible Server."
  type        = bool
}
variable "postgresql_flexible_server_administrator_login" {
  description = "The administrator login for the PostgreSQL Flexible Server."
  type        = string
}

variable "postgresql_flexible_server_zone" {
  description = "The availability zone of the PostgreSQL Flexible Server."
  type        = string
}
variable "postgresql_flexible_server_storage_mb" {
  description = "The storage size in MB for the PostgreSQL Flexible Server."
  type        = number
}
variable "postgresql_flexible_server_storage_tier" {
  description = "The storage tier for the PostgreSQL Flexible Server."
  type        = string
}
variable "postgresql_flexible_server_sku_name" {
  description = "The SKU name for the PostgreSQL Flexible Server."
  type        = string
}
variable "postgresql_flexible_server_high_availability_mode" {
  description = "The high availability mode for the PostgreSQL Flexible Server."
  type        = string
  default     = ""
}
variable "postgresql_flexible_server_database_collation" {
  description = "The collation for the PostgreSQL Flexible Server database."
  type        = string
}
variable "postgresql_flexible_server_database_charset" {
  description = "The character set for the PostgreSQL Flexible Server database."
  type        = string
}