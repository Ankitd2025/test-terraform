# Terraform Variables for the Hub and Operations Environment

# Variables for the Hub Environment
hub_subscription_id     = "886e97b0-f259-4c79-8ac0-984dbc60bbee"
hub_resource_group_name = "rg-xencia-hub-eus2-001"
hub_vnet_name           = "vnet-xencia-hub-eus2-001"
hub_firewall_name       = "afw-xencia-hub-eus2-001"
hub_bastion_subnet_name = "AzureBastionSubnet"
# End of the Hub environment configuration

# Terraform Variables for the Spoke Environment
# Variables for the Virtual Network in the Operations environment
ops_resource_group_name = "rg-gh-eus2-ops"
ops_vnet_name           = "vnet-gh-eus2-ops"
# End of virtual network configuration for the Operations environment

# Subscription and Provider Configuration for the Spoke Environment
 subscription_id = "886e97b0-f259-4c79-8ac0-984dbc60bbee"

# Local variables for the Spoke environment, including subscription and provider configuration, as well as environment-specific settings.
project_name = "xencia"
env          = "prod"
region_code  = "eus2"
region       = "canadacentral"
instance     = "001"
# End of Local variables for the Spoke environment

# Variables for the Virtual Network in the Spoke environment
address_space = ["100.64.48.0/20"]
# End of virtual network configuration for the Spoke environment

# Varibales for the Subnets in the Spoke environment
subnets = {
  "ApplicationGatewaySubnet" = {
    subnet_name                       = "appgw"
    address_prefixes                  = ["100.64.48.0/24"]
    private_endpoint_network_policies = "RouteTableEnabled"
    create_nsg                        = false
  },
  "ACRSubnet" = {
    subnet_name                       = "acr"
    address_prefixes                  = ["100.64.49.0/24"]
    private_endpoint_network_policies = "RouteTableEnabled"
    create_nsg                        = false
  },
  "AKSSystemNodesSubnet" = {
    subnet_name                       = "aks"
    address_prefixes                  = ["100.64.50.0/24"]
    private_endpoint_network_policies = "RouteTableEnabled"
    create_nsg                        = false
  },
  "AKSUserNodesSubnet" = {
    subnet_name                       = "aks-user"
    address_prefixes                  = ["100.64.51.0/24"]
    private_endpoint_network_policies = "RouteTableEnabled"
    create_nsg                        = false
  },
  "DataSubnet" = {
    subnet_name                       = "data"
    address_prefixes                  = ["100.64.52.0/22"]
    private_endpoint_network_policies = "RouteTableEnabled"
    create_nsg                        = false
    delegation_name                   = "postgresql-delegation"
    delegation_service_name           = "Microsoft.DBforPostgreSQL/flexibleServers"

    delegation_actions = [
      "Microsoft.Network/virtualNetworks/subnets/action"
    ]
  },
  "PrivateEndpointSubnet" = {
    subnet_name                       = "pvt"
    address_prefixes                  = ["100.64.56.0/24"]
    private_endpoint_network_policies = "RouteTableEnabled"
    create_nsg                        = false
  }
}

# Variables for Azure Key Vault module - CMK
kv_suffix = "fi"
# End of variables for Azure Key Vault module - CMK

# Variables for the Azure Key Vault Secret Management with Customer-Managed Keys (CMK) module
key_type             = "RSA"
key_size             = 3072
key_opts             = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
time_after_creation  = "P365D"
notify_before_expiry = "P30D"
expire_after         = "P730D"
# End of variables for the Azure Key Vault Secret Management with Customer-Managed Keys (CMK) module

# Variables for Azure Storage Account module
stg_blob_suffix = "ifi"
# End of variables for Azure Storage Account module

# Variables for the Azure Container Registry
acr_sku = "Premium"
# End of variables for the Azure Container Registry

# Variables for the Virtual Network Peering between the Operations and Spoke environments
ops_allow_virtual_network_access = true
ops_allow_forwarded_traffic      = true
ops_allow_gateway_transit        = false
ops_use_remote_gateways          = false
# End of virtual network peering configuration for the Operations and Spoke environments

# Variables for the Virtual Network Peering between the Hub and Spoke environments
hub_allow_virtual_network_access = true
hub_allow_forwarded_traffic      = true
hub_allow_gateway_transit        = true
hub_use_remote_gateways          = false
# End of virtual network peering configuration for the Hub environment

# Variables for the Virtual Network Peering between the Spoke and Hub environments
spoke_allow_virtual_network_access = true
spoke_allow_forwarded_traffic      = true
spoke_allow_gateway_transit        = false
spoke_use_remote_gateways          = true
# End of virtual network peering configuration for the Spoke environment
# Variables for Azure Managed Redis
managed_redis_sku_name                           = "MemoryOptimized_M20"
managed_redis_high_availability_enabled          = true
managed_redis_public_network_access              = "Disabled"
managed_redis_access_keys_authentication_enabled = true
managed_redis_client_protocol                    = "Encrypted"
managed_redis_clustering_policy                  = "EnterpriseCluster"
managed_redis_eviction_policy                    = "VolatileLRU"
managed_redis_private_endpoint_subresource_names = ["redisEnterprise"]
# End of variables for Azure Managed Redis

# Variables for the Azure Kubernetes Service
aks_admin_group_object_ids              = ["d3e8ce41-490d-4689-af1d-50c10575617c"]
aks_kubernetes_version                  = null
aks_sku_tier                            = "Standard"
aks_system_node_pool_vm_size            = "Standard_D2as_v6"
aks_system_node_pool_min_count          = 1
aks_system_node_pool_max_count          = 2
aks_system_node_pool_zones              = []
aks_system_node_pool_os_disk_size_gb    = 128
aks_network_plugin_mode                 = "overlay"
aks_network_policy                      = "cilium"
aks_network_data_plane                  = "cilium"
aks_outbound_type                       = "loadBalancer"
aks_service_cidr                        = "10.1.0.0/16"
aks_dns_service_ip                      = "10.1.0.10"
aks_monitor_metrics_enabled             = true
aks_monitor_metrics_annotations_allowed = null
aks_monitor_metrics_labels_allowed      = null
# End of variables for the Azure Kubernetes Service

# Variables for the Azure Kubernetes Service User Node Pool
aks_user_node_pool_name                        = "usernp"
aks_user_node_pool_vm_size                     = "Standard_D2as_v6"
aks_user_node_pool_auto_scaling_enabled        = true
aks_user_node_pool_node_count                  = 1
aks_user_node_pool_min_count                   = 1
aks_user_node_pool_max_count                   = 2
aks_user_node_pool_zones                       = []
aks_user_node_pool_os_sku                      = "Ubuntu"
aks_user_node_pool_os_disk_size_gb             = 128
aks_user_node_pool_max_pods                    = 30
aks_user_node_pool_node_labels                 = { workload = "user" }
aks_user_node_pool_node_taints                 = []
aks_user_node_pool_temporary_name_for_rotation = "usernp01"
# End of variables for the Azure Kubernetes Service User Node Pool


# Variables for Multiple Kubernetes Namespaces
kubernetes_namespaces = {
  "k8s-ns-01" = {
    name = "prod"
  }
}
# End of variables for Multiple Kubernetes Namespaces

# Variables for Multiple Kubernetes Service Account
kubernetes_service_accounts = {
  "k8s-sa-01" = {
    name      = "core-webservice-sa"
    namespace = "prod"
  },
}
# End of variables for Multiple Kubernetes Service Account

# Variables for Application Insights
application_insights_application_type           = "web"
application_insights_daily_data_cap_in_gb       = 100
application_insights_retention_in_days          = 90
application_insights_sampling_percentage        = 100
application_insights_internet_ingestion_enabled = false
application_insights_internet_query_enabled     = false

# Variables for PostgreSQL Flexible Server
postgresql_flexible_server_administrator_login           = "psqladmin"
postgresql_flexible_server_version                       = "15"
postgresql_flexible_server_storage_mb                    = 32768
postgresql_flexible_server_storage_tier                  = "P4"
postgresql_flexible_server_sku_name                      = "GP_Standard_D4s_v3"
postgresql_flexible_server_database_collation            = "en_US.utf8"
postgresql_flexible_server_database_charset              = "UTF8"
postgresql_flexible_server_high_availability_mode        = "ZoneRedundant"
postgresql_flexible_server_public_network_access_enabled = false
postgresql_flexible_server_zone                          = "1"


