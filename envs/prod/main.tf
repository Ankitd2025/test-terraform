# Configure the Azure Resource Group
module "azurerm_resource_group" {
  source   = "../../modules/resource-group"
  name     = lower("rg-${local.resources_name_suffix}")
  location = local.region
  tags     = merge(local.common_tags, { ROLE = "RESOURCEGROUP" })
}

# Configure the Azure Log Analytics Workspace
module "azurerm_log_analytics_workspace" {
  source                     = "../../modules/log-analytics-workspaces"
  name                       = lower("log-${local.resources_name_suffix}")
  location                   = local.region
  resource_group_name        = module.azurerm_resource_group.resource_group_name
  internet_ingestion_enabled = false
  internet_query_enabled     = false
  sku                        = "PerGB2018"
  retention_in_days          = 30
  daily_quota_gb             = 1
  tags                       = merge(local.common_tags, { ROLE = "LOGANALYTICSWORKSPACE" })
  depends_on                 = [module.azurerm_resource_group]
}

# Configure the Azure Virtual Network
module "azurerm_virtual_network" {
  source              = "../../modules/virtual-network"
  name                = lower("vnet-${local.resources_name_suffix}")
  location            = local.region
  resource_group_name = module.azurerm_resource_group.resource_group_name
  address_space       = var.address_space
  tags                = merge(local.common_tags, { ROLE = "VIRTUALNETWORK" })
  depends_on          = [module.azurerm_resource_group, module.azurerm_log_analytics_workspace]
}

# Configure the Azure Subnet
module "azurerm_subnet" {
  source                            = "../../modules/subnet-spoke"
  for_each                          = var.subnets
  name                              = lower("snet-${each.value.subnet_name}-${local.env}-${local.region_code}-${local.instance}")
  resource_group_name               = module.azurerm_resource_group.resource_group_name
  virtual_network_name              = module.azurerm_virtual_network.name
  address_prefixes                  = each.value.address_prefixes
  private_endpoint_network_policies = each.value.private_endpoint_network_policies
  delegation_name                   = lookup(each.value, "delegation_name", null)
  delegation_service_name           = lookup(each.value, "delegation_service_name", null)
  delegation_actions                = lookup(each.value, "delegation_actions", null)
  service_endpoints                 = lookup(each.value, "service_endpoints", null)
  create_nsg                        = lookup(each.value, "create_nsg", false)
  location                          = local.region
  tags                              = merge(local.common_tags, { ROLE = "SUBNET" })
  depends_on                        = [module.azurerm_virtual_network]
}


# Configure the Azure Key Vault
module "azurerm_key_vault_cmk" {
  source                        = "../../modules/key-vault"
  name                          = lower("kv-${var.kv_suffix}-${local.env}-${local.region_code}-${local.instance}")
  location                      = local.region
  resource_group_name           = module.azurerm_resource_group.resource_group_name
  tenant_id                     = data.azurerm_client_config.azurerm_client_config.tenant_id
  public_network_access_enabled = false
  rbac_authorization_enabled    = true
  soft_delete_retention_days    = 7
  purge_protection_enabled      = false
  sku_name                      = "standard"
  principal_id                  = data.azurerm_client_config.azurerm_client_config.object_id
  tags                          = merge(local.common_tags, { ROLE = "CMK" })
  depends_on                    = [module.azurerm_resource_group, module.azurerm_virtual_network_peering_hub_to_spoke, module.azurerm_virtual_network_peering_spoke_to_hub, data.azurerm_client_config.azurerm_client_config]
}


# Configure the Azure Key Vault Key for Customer-Managed Keys (CMK)
module "azurerm_key_vault_cmk_key" {
  source               = "../../modules/key-vault-cmk"
  name                 = lower("key-${local.resources_name_suffix}")
  key_vault_id         = module.azurerm_key_vault_cmk.key_vault_id
  key_type             = var.key_type
  key_size             = var.key_size
  key_opts             = var.key_opts
  time_after_creation  = var.time_after_creation
  notify_before_expiry = var.notify_before_expiry
  expire_after         = var.expire_after
  tags                 = merge(local.common_tags, { ROLE = "CMK" })
  depends_on           = [module.azurerm_key_vault_cmk, module.azurerm_private_endpoint_keyvault]
}

# Configure the Azure Private DNS Zone for Azure Key Vault
module "azurerm_private_dns_zone_keyvault" {
  source              = "../../modules/private-dns-zone"
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = module.azurerm_resource_group.resource_group_name
  tags                = merge(local.common_tags, { ROLE = "PRIVATEDNSZONE" })
  depends_on          = [module.azurerm_resource_group, data.azurerm_client_config.azurerm_client_config]
}

# Configure the Azure Private Endpoint for Azure Key Vault
module "azurerm_private_endpoint_keyvault" {
  source                         = "../../modules/private-endpoints"
  name                           = lower("pe-${module.azurerm_key_vault_cmk.key_vault_name}")
  location                       = local.region
  resource_group_name            = module.azurerm_resource_group.resource_group_name
  subnet_id                      = module.azurerm_subnet["PrivateEndpointSubnet"].id
  private_connection_resource_id = module.azurerm_key_vault_cmk.key_vault_id
  subresource_names              = ["vault"]
  private_dns_zone_ids           = [module.azurerm_private_dns_zone_keyvault.azurerm_private_dns_zone_id]
  tags                           = merge(local.common_tags, { ROLE = "PRIVATEENDPOINT" })
  depends_on                     = [module.azurerm_key_vault_cmk, module.azurerm_private_dns_zone_keyvault]
}

# Configure the Azure Virtual Network Link for the Private DNS Zone
module "azurerm_private_dns_zone_vnet_link_keyvault" {
  source                = "../../modules/virtual-network-links"
  name                  = lower("link-${module.azurerm_virtual_network.name}")
  resource_group_name   = module.azurerm_resource_group.resource_group_name
  private_dns_zone_name = module.azurerm_private_dns_zone_keyvault.azurerm_private_dns_zone_name
  virtual_network_id    = module.azurerm_virtual_network.id
  tags                  = merge(local.common_tags, { ROLE = "PRIVATEDNSZONEVNETLINK" })
  depends_on            = [module.azurerm_private_dns_zone_keyvault, module.azurerm_virtual_network]
}

# Configure the Azure Application Gateway with public and private frontends
module "azurerm_application_gateway" {
  source                          = "../../modules/application-gateway"
  name                            = lower("agw-${local.resources_name_suffix}")
  public_ip_name                  = lower("pip-agw-${local.resources_name_suffix}")
  identity_name                   = lower("id-agw-${local.resources_name_suffix}")
  resource_group_name             = module.azurerm_resource_group.resource_group_name
  location                        = local.region
  subnet_id                       = module.azurerm_subnet["ApplicationGatewaySubnet"].id
  private_ip_address              = cidrhost(var.subnets["ApplicationGatewaySubnet"].address_prefixes[0], 10)
  sku_name                        = var.application_gateway_sku_name
  key_vault_id                    = module.azurerm_key_vault_cmk.key_vault_id
  key_vault_certificate_secret_id = var.application_gateway_key_vault_certificate_secret_id
  tags                            = merge(local.common_tags, { ROLE = "APPLICATIONGATEWAY" })
  depends_on                      = [module.azurerm_subnet, module.azurerm_key_vault_cmk, module.azurerm_log_analytics_workspace]
}

# Configure the Azure Storage Account for Network Watcher Flow Logs
module "azurerm_storage_account_blob" {
  source                                 = "../../modules/storage-account"
  name                                   = lower("st${var.stg_blob_suffix}${local.env}${local.region_code}${local.instance}")
  resource_group_name                    = module.azurerm_resource_group.resource_group_name
  location                               = local.region
  account_tier                           = "Standard"
  account_replication_type               = "GRS"
  account_kind                           = "StorageV2"
  public_network_access_enabled          = false
  min_tls_version                        = "TLS1_2"
  https_traffic_only_enabled             = true
  allow_nested_items_to_be_public        = false
  shared_access_key_enabled              = false
  versioning_enabled                     = true
  container_delete_retention_policy_days = 7
  delete_retention_policy_days           = 7
  enable_https_traffic_only              = true
  network_rules_bypass                   = ["AzureServices"]
  network_rules_default_action           = "Deny"
  tags                                   = merge(local.common_tags, { ROLE = "BLOBSTORAGE" })
  depends_on                             = [module.azurerm_resource_group]
}


# Configure the Azure Key Vault RBAC IAM for the Storage Account (using Hub Key Vault)
module "azurerm_role_assignment_storage_account_blob_keyvault" {
  source               = "../../modules/rbac"
  scope                = module.azurerm_key_vault_cmk.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = module.azurerm_storage_account_blob.storage_account_identity[0].principal_id
  depends_on           = [module.azurerm_storage_account_blob]
}

# Configure the Private DNS Zone for Storage Account
module "azurerm_private_dns_zone_storage" {
  source              = "../../modules/private-dns-zone"
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = module.azurerm_resource_group.resource_group_name
  tags                = merge(local.common_tags, { ROLE = "PRIVATEDNSZONE" })
  depends_on          = [module.azurerm_resource_group]
}

# Configure the Azure Private Endpoint for Storage Account
module "azurerm_private_endpoint_storage_blob" {
  source                         = "../../modules/private-endpoints"
  name                           = lower("pe-${module.azurerm_storage_account_blob.storage_account_name}")
  location                       = local.region
  resource_group_name            = module.azurerm_resource_group.resource_group_name
  subnet_id                      = module.azurerm_subnet["PrivateEndpointSubnet"].id
  private_connection_resource_id = module.azurerm_storage_account_blob.storage_account_id
  subresource_names              = ["blob"]
  private_dns_zone_ids           = [module.azurerm_private_dns_zone_storage.azurerm_private_dns_zone_id]
  tags                           = merge(local.common_tags, { ROLE = "PRIVATEENDPOINT" })
  depends_on                     = [module.azurerm_storage_account_blob, module.azurerm_private_dns_zone_storage]
}


# Configure the Private DNS Zone for Container Registry
module "azurerm_private_dns_zone_acr" {
  source              = "../../modules/private-dns-zone"
  name                = "privatelink.azurecr.io"
  resource_group_name = module.azurerm_resource_group.resource_group_name
  tags                = merge(local.common_tags, { ROLE = "PRIVATEDNSZONE" })
  depends_on          = [module.azurerm_resource_group]
}

# Configure the Azure Container Registry
module "azurerm_container_registry" {
  source                        = "../../modules/container-registry"
  name                          = lower("acr${local.env}${local.region_code}${local.instance}")
  resource_group_name           = module.azurerm_resource_group.resource_group_name
  location                      = local.region
  sku                           = var.acr_sku
  admin_enabled                 = false
  public_network_access_enabled = false
  quarantine_policy_enabled     = false
  zone_redundancy_enabled       = false
  anonymous_pull_enabled        = false
  data_endpoint_enabled         = false
  geo_replications              = var.acr_geo_replications
  tags                          = merge(local.common_tags, { ROLE = "CONTAINERREGISTRY" })
  depends_on                    = [module.azurerm_resource_group]
}

# Configure the Azure Private Endpoint for Container Registry
module "azurerm_private_endpoint_container_registry" {
  source                         = "../../modules/private-endpoints"
  name                           = lower("pe-${module.azurerm_container_registry.container_registry_name}")
  location                       = local.region
  resource_group_name            = module.azurerm_resource_group.resource_group_name
  subnet_id                      = module.azurerm_subnet["ACRSubnet"].id
  private_connection_resource_id = module.azurerm_container_registry.container_registry_id
  subresource_names              = ["registry"]
  private_dns_zone_ids           = [module.azurerm_private_dns_zone_acr.azurerm_private_dns_zone_id]
  tags                           = merge(local.common_tags, { ROLE = "PRIVATEENDPOINT" })
  depends_on                     = [module.azurerm_container_registry, module.azurerm_private_dns_zone_acr]
}

# Configure the Azure Virtual Network Link for the Private DNS Zone for Storage Account
module "azurerm_private_dns_zone_vnet_link_storage_blob" {
  source                = "../../modules/virtual-network-links"
  name                  = lower("link-${module.azurerm_virtual_network.name}-blob")
  resource_group_name   = module.azurerm_resource_group.resource_group_name
  private_dns_zone_name = module.azurerm_private_dns_zone_storage.azurerm_private_dns_zone_name
  virtual_network_id    = module.azurerm_virtual_network.id
  tags                  = merge(local.common_tags, { ROLE = "PRIVATEDNSZONEVNETLINK" })
  depends_on            = [module.azurerm_private_dns_zone_storage, module.azurerm_virtual_network]
}

# Configure the Azure Virtual Network Link for the Private DNS Zone for Container Registry
module "azurerm_private_dns_zone_vnet_link_container_registry" {
  source                = "../../modules/virtual-network-links"
  name                  = lower("link-${module.azurerm_virtual_network.name}-acr")
  resource_group_name   = module.azurerm_resource_group.resource_group_name
  private_dns_zone_name = module.azurerm_private_dns_zone_acr.azurerm_private_dns_zone_name
  virtual_network_id    = module.azurerm_virtual_network.id
  tags                  = merge(local.common_tags, { ROLE = "PRIVATEDNSZONEVNETLINK" })
  depends_on            = [module.azurerm_private_dns_zone_acr, module.azurerm_virtual_network]
}

# Configure the Azure Route Table
module "azurerm_route_table" {
  source              = "../../modules/route-table"
  name                = lower("rt-${local.resources_name_suffix}")
  location            = local.region
  resource_group_name = module.azurerm_resource_group.resource_group_name
  route = [{
    name                = "default-to-hub-firewall"
    address_prefix      = "0.0.0.0/0"
    next_hop_type       = "VirtualAppliance"
    next_hop_ip_address = data.azurerm_firewall.hub_firewall.ip_configuration[0].private_ip_address
  }]
  tags       = merge(local.common_tags, { ROLE = "ROUTETABLE" })
  depends_on = [module.azurerm_resource_group, data.azurerm_firewall.hub_firewall]
}

# Associate the Route Table with the Self-Hosted Integration Runtime Subnet
# Associate the AKS Route Table with the System Node Subnet
module "azurerm_subnet_route_table_association_aks_system_nodes" {
  source         = "../../modules/route-table-subnet"
  subnet_id      = module.azurerm_subnet["AKSSystemNodesSubnet"].id
  route_table_id = module.azurerm_route_table.route_table_id
  depends_on     = [module.azurerm_subnet, module.azurerm_route_table]
}

# Associate the AKS Route Table with the User Node Subnet
module "azurerm_subnet_route_table_association_aks_user_nodes" {
  source         = "../../modules/route-table-subnet"
  subnet_id      = module.azurerm_subnet["AKSUserNodesSubnet"].id
  route_table_id = module.azurerm_route_table.route_table_id
  depends_on     = [module.azurerm_subnet, module.azurerm_route_table]
}

# Associate the Route Table with the Private Endpoint Subnet
module "azurerm_subnet_route_table_association_private_endpoint" {
  source         = "../../modules/route-table-subnet"
  subnet_id      = module.azurerm_subnet["PrivateEndpointSubnet"].id
  route_table_id = module.azurerm_route_table.route_table_id
  depends_on     = [module.azurerm_subnet, module.azurerm_route_table]
}

module "azurerm_subnet_route_table_association_data" {
  source         = "../../modules/route-table-subnet"
  subnet_id      = module.azurerm_subnet["DataSubnet"].id
  route_table_id = module.azurerm_route_table.route_table_id
  depends_on     = [module.azurerm_subnet, module.azurerm_route_table]
}

module "azurerm_subnet_route_table_association_acr" {
  source         = "../../modules/route-table-subnet"
  subnet_id      = module.azurerm_subnet["ACRSubnet"].id
  route_table_id = module.azurerm_route_table.route_table_id
  depends_on     = [module.azurerm_subnet, module.azurerm_route_table]
}

# Configure the Azure Virtual Network Peering between the Operations and Spoke Virtual Networks
module "azurerm_virtual_network_peering_ops_to_spoke" {
  source                       = "../../modules/virtual-network-peering"
  name                         = lower("${data.azurerm_virtual_network.operations_vnet.name}-to-${module.azurerm_virtual_network.name}")
  resource_group_name          = data.azurerm_virtual_network.operations_vnet.resource_group_name
  virtual_network_name         = data.azurerm_virtual_network.operations_vnet.name
  remote_virtual_network_id    = module.azurerm_virtual_network.id
  allow_virtual_network_access = var.ops_allow_virtual_network_access
  allow_forwarded_traffic      = var.ops_allow_forwarded_traffic
  allow_gateway_transit        = var.ops_allow_gateway_transit
  use_remote_gateways          = var.ops_use_remote_gateways
  depends_on                   = [module.azurerm_virtual_network, module.azurerm_subnet]
  providers = {
    azurerm = azurerm.hub
  }
}

# Configure the Azure Virtual Network Peering between the Spoke and Operations Virtual Networks
module "azurerm_virtual_network_peering_spoke_to_ops" {
  source                       = "../../modules/virtual-network-peering"
  name                         = lower("${module.azurerm_virtual_network.name}-to-${data.azurerm_virtual_network.operations_vnet.name}")
  resource_group_name          = module.azurerm_virtual_network.resource_group_name
  virtual_network_name         = module.azurerm_virtual_network.name
  remote_virtual_network_id    = data.azurerm_virtual_network.operations_vnet.id
  allow_virtual_network_access = var.ops_allow_virtual_network_access
  allow_forwarded_traffic      = var.ops_allow_forwarded_traffic
  allow_gateway_transit        = var.ops_allow_gateway_transit
  use_remote_gateways          = var.ops_use_remote_gateways
  depends_on                   = [module.azurerm_virtual_network, module.azurerm_subnet, module.azurerm_virtual_network_peering_ops_to_spoke]
}

# Configure the Azure Virtual Network Peering between the Hub and Spoke Virtual Networks
module "azurerm_virtual_network_peering_hub_to_spoke" {
  source                       = "../../modules/virtual-network-peering"
  name                         = lower("${data.azurerm_virtual_network.hub_vnet.name}-to-${module.azurerm_virtual_network.name}")
  resource_group_name          = data.azurerm_virtual_network.hub_vnet.resource_group_name
  virtual_network_name         = data.azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id    = module.azurerm_virtual_network.id
  allow_virtual_network_access = var.hub_allow_virtual_network_access
  allow_forwarded_traffic      = var.hub_allow_forwarded_traffic
  allow_gateway_transit        = var.hub_allow_gateway_transit
  use_remote_gateways          = var.hub_use_remote_gateways
  depends_on                   = [module.azurerm_virtual_network, module.azurerm_subnet]
  providers = {
    azurerm = azurerm.hub
  }
}

# Configure the Azure Virtual Network Peering between the Spoke and Hub Virtual Networks
module "azurerm_virtual_network_peering_spoke_to_hub" {
  source                       = "../../modules/virtual-network-peering"
  name                         = lower("${module.azurerm_virtual_network.name}-to-${data.azurerm_virtual_network.hub_vnet.name}")
  resource_group_name          = module.azurerm_virtual_network.resource_group_name
  virtual_network_name         = module.azurerm_virtual_network.name
  remote_virtual_network_id    = data.azurerm_virtual_network.hub_vnet.id
  allow_virtual_network_access = var.spoke_allow_virtual_network_access
  allow_forwarded_traffic      = var.spoke_allow_forwarded_traffic
  allow_gateway_transit        = var.spoke_allow_gateway_transit
  use_remote_gateways          = var.spoke_use_remote_gateways
  depends_on                   = [module.azurerm_virtual_network, module.azurerm_subnet]
}
# configure application insights
module "azurerm_application_insights" {
  source                     = "../../modules/application-insights"
  name                       = lower("ai-${local.resources_name_suffix}")
  location                   = local.region
  resource_group_name        = module.azurerm_resource_group.resource_group_name
  application_type           = var.application_insights_application_type
  workspace_id               = module.azurerm_log_analytics_workspace.log_analytics_workspace_resource_id
  daily_data_cap_in_gb       = var.application_insights_daily_data_cap_in_gb
  retention_in_days          = var.application_insights_retention_in_days
  sampling_percentage        = var.application_insights_sampling_percentage
  internet_ingestion_enabled = var.application_insights_internet_ingestion_enabled
  internet_query_enabled     = var.application_insights_internet_query_enabled
  tags                       = merge(local.common_tags, { ROLE = "APPLICATIONINSIGHTS" })
  depends_on                 = [module.azurerm_resource_group, module.azurerm_log_analytics_workspace]
}

# Configure the Private DNS Zone for postagresql flexible server
module "azurerm_private_dns_zone_postgresql" {
  source              = "../../modules/private-dns-zone"
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = module.azurerm_resource_group.resource_group_name
  tags                = merge(local.common_tags, { ROLE = "PRIVATEDNSZONE" })
  depends_on          = [module.azurerm_resource_group]
}

# Configure the Virtual Network Link for the postagresql flexible server Private DNS Zone
module "azurerm_private_dns_zone_vnet_link_postgresql" {
  source                = "../../modules/virtual-network-links"
  name                  = lower("link-${module.azurerm_virtual_network.name}")
  resource_group_name   = module.azurerm_resource_group.resource_group_name
  private_dns_zone_name = module.azurerm_private_dns_zone_postgresql.azurerm_private_dns_zone_name
  virtual_network_id    = module.azurerm_virtual_network.id
  tags                  = merge(local.common_tags, { ROLE = "PRIVATEDNSZONEVNETLINK" })
  depends_on            = [module.azurerm_private_dns_zone_postgresql, module.azurerm_virtual_network]
}

# Generate the postgresql flexible server administrator password
resource "random_password" "postgresql_flexible_server_administrator_password" {
  length           = 16
  special          = true
  min_lower        = 6
  min_upper        = 5
  min_numeric      = 4
  min_special      = 1
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store the PostgreSQL flexible server administrator password in Key Vault
module "azurerm_key_vault_secret_postgresql_flexible_server_administrator_password" {
  source       = "../../modules/key-vault-secret"
  name         = lower("secret-${local.resources_name_suffix}-psql-admin-password")
  value        = random_password.postgresql_flexible_server_administrator_password.result
  key_vault_id = module.azurerm_key_vault_cmk.key_vault_id
  content_type = "PostgreSQL flexible server administrator password"
  tags         = merge(local.common_tags, { ROLE = "POSTGRESQLFLEXIBLESERVERSECRET" })
  depends_on   = [random_password.postgresql_flexible_server_administrator_password, module.azurerm_key_vault_cmk]
}

#configure postgresql flexible server
module "azurerm_postgresql_flexible_server" {
  source                        = "../../modules/postgresql-server"
  name                          = lower("psql-${local.resources_name_suffix}")
  location                      = local.region
  resource_group_name           = module.azurerm_resource_group.resource_group_name
  server_version                = var.postgresql_flexible_server_version
  delegated_subnet_id           = module.azurerm_subnet["DataSubnet"].id
  private_dns_zone_id           = module.azurerm_private_dns_zone_postgresql.azurerm_private_dns_zone_id
  public_network_access_enabled = var.postgresql_flexible_server_public_network_access_enabled
  administrator_login           = var.postgresql_flexible_server_administrator_login
  administrator_password        = random_password.postgresql_flexible_server_administrator_password.result
  zone                          = var.postgresql_flexible_server_zone
  storage_mb                    = var.postgresql_flexible_server_storage_mb
  storage_tier                  = var.postgresql_flexible_server_storage_tier
  sku_name                      = var.postgresql_flexible_server_sku_name
  high_availability_mode        = var.postgresql_flexible_server_high_availability_mode
  database_name                 = "psqldb-${module.azurerm_postgresql_flexible_server.postgresql_flexible_server_name}"
  database_collation            = var.postgresql_flexible_server_database_collation
  database_charset              = var.postgresql_flexible_server_database_charset
  tags                          = merge(local.common_tags, { ROLE = "POSTGRESQLFLEXIBLESERVER" })
  depends_on                    = [module.azurerm_resource_group, module.azurerm_private_dns_zone_postgresql, module.azurerm_subnet, module.azurerm_private_dns_zone_vnet_link_postgresql, module.azurerm_key_vault_secret_postgresql_flexible_server_administrator_password]
}

# Configure Azure Managed Redis 
module "azurerm_managed_amr" {
  source                             = "../../modules/managed-redis"
  name                               = lower("amr-${local.resources_name_suffix}")
  resource_group_name                = module.azurerm_resource_group.resource_group_name
  location                           = local.region
  sku_name                           = var.managed_redis_sku_name
  high_availability_enabled          = var.managed_redis_high_availability_enabled
  public_network_access              = var.managed_redis_public_network_access
  access_keys_authentication_enabled = var.managed_redis_access_keys_authentication_enabled
  client_protocol                    = var.managed_redis_client_protocol
  clustering_policy                  = var.managed_redis_clustering_policy
  eviction_policy                    = var.managed_redis_eviction_policy
  key_vault_key_id                   = module.azurerm_key_vault_cmk_key.key_vault_cmk_key_id
  user_assigned_identity_id          = module.azurerm_user_assigned_identity_amr.azurerm_user_assigned_identity_id
  tags                               = merge(local.common_tags, { ROLE = "MANAGEDREDIS" })
  depends_on                         = [module.azurerm_resource_group, module.azurerm_log_analytics_workspace, module.azurerm_user_assigned_identity_amr, module.azurerm_role_assignment_managed_redis_keyvault, module.azurerm_key_vault_cmk_key, module.azurerm_private_endpoint_keyvault]
}

# Store the Azure Managed Redis Primary access key in Key Vault
module "azurerm_key_vault_secret_managed_amr_primary_access_key" {
  source       = "../../modules/key-vault-secret"
  name         = lower("secret-amr-primary-access-key")
  value        = module.azurerm_managed_amr.managed_redis_primary_access_key
  key_vault_id = module.azurerm_key_vault_cmk.key_vault_id
  content_type = "Azure Managed Redis Primary access key"
  tags         = merge(local.common_tags, { ROLE = "MANAGEDREDISSECRET" })
  depends_on   = [module.azurerm_managed_amr, module.azurerm_key_vault_cmk, module.azurerm_private_endpoint_keyvault, module.azurerm_virtual_network_peering_ops_to_spoke]
}

# Store the Azure Managed Redis Primary secondary access key in Key Vault
module "azurerm_key_vault_secret_managed_amr_secondary_access_key" {
  source       = "../../modules/key-vault-secret"
  name         = lower("secret-amr-secondary-access-key")
  value        = module.azurerm_managed_amr.managed_redis_secondary_access_key
  key_vault_id = module.azurerm_key_vault_cmk.key_vault_id
  content_type = "Azure Managed Redis Primary secondary access key"
  tags         = merge(local.common_tags, { ROLE = "MANAGEDREDISSECRET" })
  depends_on   = [module.azurerm_managed_amr, module.azurerm_key_vault_cmk, module.azurerm_private_endpoint_keyvault, module.azurerm_virtual_network_peering_ops_to_spoke]
}

# Configure the Private DNS Zone for managed Redis
module "azurerm_private_dns_zone_managed_redis" {
  source              = "../../modules/private-dns-zone"
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = module.azurerm_resource_group.resource_group_name
  tags                = merge(local.common_tags, { ROLE = "PRIVATEDNSZONE" })
  depends_on          = [module.azurerm_resource_group]
}

# Configure the Azure Private Endpoint for Azure Managed Redis Primary
module "azurerm_private_endpoint_managed_amr" {
  source                         = "../../modules/private-endpoints"
  name                           = lower("pe-${module.azurerm_managed_amr.managed_redis_name}")
  location                       = local.region
  resource_group_name            = module.azurerm_resource_group.resource_group_name
  subnet_id                      = module.azurerm_subnet["PrivateEndpointSubnet"].id
  private_connection_resource_id = module.azurerm_managed_amr.managed_redis_id
  subresource_names              = ["redisCache"]
  private_dns_zone_ids           = [module.azurerm_private_dns_zone_managed_redis.azurerm_private_dns_zone_id]
  tags                           = merge(local.common_tags, { ROLE = "PRIVATEENDPOINT" })
  depends_on                     = [module.azurerm_managed_amr, module.azurerm_private_dns_zone_managed_redis]
}

# Configure the Virtual Network Link for the Azure Managed Redis Private DNS Zone
module "azurerm_private_dns_zone_vnet_link_managed_redis" {
  source                = "../../modules/virtual-network-links"
  name                  = lower("link-${module.azurerm_virtual_network.name}")
  resource_group_name   = module.azurerm_resource_group.resource_group_name
  private_dns_zone_name = module.azurerm_private_dns_zone_managed_redis.azurerm_private_dns_zone_name
  virtual_network_id    = module.azurerm_virtual_network.id
  tags                  = merge(local.common_tags, { ROLE = "PRIVATEDNSZONEVNETLINK" })
  depends_on            = [module.azurerm_private_dns_zone_managed_redis, module.azurerm_virtual_network]
}

# Configure the Azure User Assigned Managed Identity for the Azure Managed Redis Primary
module "azurerm_user_assigned_identity_amr" {
  source              = "../../modules/managed-identity"
  name                = lower("uami-amr-${local.resources_name_suffix}")
  location            = local.region
  resource_group_name = module.azurerm_resource_group.resource_group_name
  tags                = merge(local.common_tags, { ROLE = "MANAGEDREDIS" })
}

# Configure Azure Managed Redis User Assigned Identity RBAC for the CMK Key Vault
module "azurerm_role_assignment_managed_redis_keyvault" {
  source               = "../../modules/rbac"
  scope                = module.azurerm_key_vault_cmk.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = module.azurerm_user_assigned_identity_amr.azurerm_user_assigned_identity_principal_id
  depends_on           = [module.azurerm_user_assigned_identity_amr, module.azurerm_key_vault_cmk]
}

# Configure the Azure Kubernetes Service User Assigned Managed Identity
module "azurerm_user_assigned_identity_aks" {
  source              = "../../modules/user-assigned-identity"
  name                = lower("id-aks-${local.resources_name_suffix}")
  resource_group_name = module.azurerm_resource_group.resource_group_name
  location            = local.region
  tags                = merge(local.common_tags, { ROLE = "AKSIDENTITY" })
  depends_on          = [module.azurerm_resource_group]
}

# Configure AKS Identity RBAC for System Node Subnet Network Operations
module "azurerm_role_assignment_aks_system_subnet_network_contributor" {
  source               = "../../modules/rbac"
  scope                = module.azurerm_subnet["AKSSystemNodesSubnet"].id
  role_definition_name = "Network Contributor"
  principal_id         = module.azurerm_user_assigned_identity_aks.user_assigned_identity_principal_id
  depends_on           = [module.azurerm_user_assigned_identity_aks, module.azurerm_subnet]
}

# Configure AKS Identity RBAC for User Node Subnet Network Operations
module "azurerm_role_assignment_aks_user_subnet_network_contributor" {
  source               = "../../modules/rbac"
  scope                = module.azurerm_subnet["AKSUserNodesSubnet"].id
  role_definition_name = "Network Contributor"
  principal_id         = module.azurerm_user_assigned_identity_aks.user_assigned_identity_principal_id
  depends_on           = [module.azurerm_user_assigned_identity_aks, module.azurerm_subnet]
}

# Configure the Private DNS Zone for AKS
module "azurerm_private_dns_zone_aks" {
  source              = "../../modules/private-dns-zone"
  name                = "privatelink.${local.region}.azmk8s.io"
  resource_group_name = module.azurerm_resource_group.resource_group_name
  tags                = merge(local.common_tags, { ROLE = "PRIVATEDNSZONE" })
  depends_on          = [module.azurerm_resource_group]
}

# Configure the Spoke Virtual Network Link for the AKS Private DNS Zone
module "azurerm_private_dns_zone_vnet_link_aks" {
  source                = "../../modules/virtual-network-links"
  name                  = lower("link-${module.azurerm_virtual_network.name}")
  resource_group_name   = module.azurerm_resource_group.resource_group_name
  private_dns_zone_name = module.azurerm_private_dns_zone_aks.azurerm_private_dns_zone_name
  virtual_network_id    = module.azurerm_virtual_network.id
  tags                  = merge(local.common_tags, { ROLE = "AKSPRIVATEDNSZONEVNETLINK" })
  depends_on            = [module.azurerm_private_dns_zone_aks, module.azurerm_virtual_network]
}

# Configure AKS Identity RBAC for the AKS Private DNS Zone
module "azurerm_role_assignment_aks_private_dns_zone" {
  source               = "../../modules/rbac"
  scope                = module.azurerm_private_dns_zone_aks.azurerm_private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = module.azurerm_user_assigned_identity_aks.user_assigned_identity_principal_id
  depends_on           = [module.azurerm_user_assigned_identity_aks, module.azurerm_private_dns_zone_aks]
}

# Configure AKS Identity RBAC for Route Table Network Operations
module "azurerm_role_assignment_aks_route_table_network_contributor" {
  source               = "../../modules/rbac"
  scope                = module.azurerm_route_table.route_table_id
  role_definition_name = "Network Contributor"
  principal_id         = module.azurerm_user_assigned_identity_aks.user_assigned_identity_principal_id
  depends_on           = [module.azurerm_user_assigned_identity_aks, module.azurerm_route_table]
}

# Configure AKS Identity RBAC for Application Gateway Subnet Network Operations
module "azurerm_role_assignment_aks_appgw_subnet_network_contributor" {
  source               = "../../modules/rbac"
  scope                = module.azurerm_subnet["ApplicationGatewaySubnet"].id
  role_definition_name = "Network Contributor"
  principal_id         = module.azurerm_user_assigned_identity_aks.user_assigned_identity_principal_id
  depends_on           = [module.azurerm_user_assigned_identity_aks, module.azurerm_subnet]
}

# Configure AKS Identity RBAC for Application Gateway IP Network Operations
module "azurerm_role_assignment_aks_appgw_ip_network_contributor" {
  source               = "../../modules/rbac"
  scope                = module.azurerm_application_gateway.application_gateway_id
  role_definition_name = "Network Contributor"
  principal_id         = module.azurerm_user_assigned_identity_aks.user_assigned_identity_principal_id
  depends_on           = [module.azurerm_user_assigned_identity_aks, module.azurerm_application_gateway]
}

# Configure AKS Identity RBAC for Application Gateway User Managed Identity Managed Identity Operator
module "azurerm_role_assignment_aks_appgw_identity_managed_identity_operator" {
  source               = "../../modules/rbac"
  scope                = module.azurerm_application_gateway.application_gateway_user_assigned_identity_id
  role_definition_name = "Managed Identity Operator"
  principal_id         = module.azurerm_user_assigned_identity_aks.user_assigned_identity_principal_id
  depends_on           = [module.azurerm_user_assigned_identity_aks, module.azurerm_application_gateway]
}

# Configure AKS Identity RBAC for Application Gateway Contributor Role Assignment
module "azurerm_role_assignment_aks_identity_appgw_contributor" {
  source               = "../../modules/rbac"
  scope                = module.azurerm_application_gateway.application_gateway_public_ip_id
  role_definition_name = "Contributor"
  principal_id         = module.azurerm_user_assigned_identity_aks.user_assigned_identity_principal_id
  depends_on           = [module.azurerm_user_assigned_identity_aks, module.azurerm_application_gateway]
}
# Configure the PCI-aligned Azure Kubernetes Service Cluster
module "azurerm_kubernetes_cluster" {
  source                              = "../../modules/kubernetes"
  name                                = lower("aks-${local.resources_name_suffix}")
  resource_group_name                 = module.azurerm_resource_group.resource_group_name
  location                            = local.region
  dns_prefix                          = lower("aks-${local.resources_name_suffix}")
  tenant_id                           = data.azurerm_client_config.azurerm_client_config.tenant_id
  admin_group_object_ids              = var.aks_admin_group_object_ids
  vnet_subnet_id                      = module.azurerm_subnet["AKSSystemNodesSubnet"].id
  kubernetes_version                  = var.aks_kubernetes_version
  sku_tier                            = var.aks_sku_tier
  private_dns_zone_id                 = module.azurerm_private_dns_zone_aks.azurerm_private_dns_zone_id
  identity_type                       = "UserAssigned"
  identity_ids                        = [module.azurerm_user_assigned_identity_aks.user_assigned_identity_id]
  default_node_pool_vm_size           = var.aks_system_node_pool_vm_size
  default_node_pool_min_count         = var.aks_system_node_pool_min_count
  default_node_pool_max_count         = var.aks_system_node_pool_max_count
  default_node_pool_zones             = var.aks_system_node_pool_zones
  default_node_pool_os_disk_size_gb   = var.aks_system_node_pool_os_disk_size_gb
  network_plugin_mode                 = var.aks_network_plugin_mode
  network_policy                      = var.aks_network_policy
  network_data_plane                  = var.aks_network_data_plane
  outbound_type                       = var.aks_outbound_type
  service_cidr                        = var.aks_service_cidr
  dns_service_ip                      = var.aks_dns_service_ip
  monitor_metrics_enabled             = var.aks_monitor_metrics_enabled
  monitor_metrics_annotations_allowed = var.aks_monitor_metrics_annotations_allowed
  monitor_metrics_labels_allowed      = var.aks_monitor_metrics_labels_allowed
  log_analytics_workspace_id          = module.azurerm_log_analytics_workspace.log_analytics_workspace_resource_id
  tags                                = merge(local.common_tags, { ROLE = "AKS" })
  depends_on                          = [module.azurerm_subnet, module.azurerm_log_analytics_workspace, module.azurerm_private_dns_zone_vnet_link_aks, module.azurerm_role_assignment_aks_private_dns_zone, module.azurerm_role_assignment_aks_system_subnet_network_contributor, module.azurerm_role_assignment_aks_user_subnet_network_contributor, module.azurerm_role_assignment_aks_route_table_network_contributor]
}

# Configure the Azure Kubernetes Service User Node Pool
module "azurerm_kubernetes_cluster_user_node_pool" {
  source                      = "../../modules/kubernetes-node"
  name                        = var.aks_user_node_pool_name
  kubernetes_cluster_id       = module.azurerm_kubernetes_cluster.kubernetes_cluster_id
  vm_size                     = var.aks_user_node_pool_vm_size
  vnet_subnet_id              = module.azurerm_subnet["AKSUserNodesSubnet"].id
  orchestrator_version        = var.aks_kubernetes_version
  auto_scaling_enabled        = var.aks_user_node_pool_auto_scaling_enabled
  node_count                  = var.aks_user_node_pool_node_count
  min_count                   = var.aks_user_node_pool_min_count
  max_count                   = var.aks_user_node_pool_max_count
  zones                       = var.aks_user_node_pool_zones
  os_sku                      = var.aks_user_node_pool_os_sku
  os_disk_size_gb             = var.aks_user_node_pool_os_disk_size_gb
  max_pods                    = var.aks_user_node_pool_max_pods
  node_labels                 = var.aks_user_node_pool_node_labels
  node_taints                 = var.aks_user_node_pool_node_taints
  temporary_name_for_rotation = var.aks_user_node_pool_temporary_name_for_rotation
  tags                        = merge(local.common_tags, { ROLE = "AKSUSERNODEPOOL" })
  depends_on                  = [module.azurerm_kubernetes_cluster]
}

# Configure ACR Pull access for AKS kubelet identity
module "azurerm_role_assignment_aks_acr_pull" {
  source               = "../../modules/rbac"
  scope                = module.azurerm_container_registry.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = module.azurerm_kubernetes_cluster.kubernetes_cluster_kubelet_identity_object_id
  depends_on           = [module.azurerm_kubernetes_cluster, module.azurerm_container_registry]
}

# Configure the Azure Kubernetes Service Admin Group RBAC for the AKS Cluster
module "azurerm_role_assignment_aks_admin_group" {
  source               = "../../modules/rbac"
  for_each             = toset(var.aks_admin_group_object_ids)
  scope                = module.azurerm_kubernetes_cluster.kubernetes_cluster_id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = each.value
  depends_on           = [module.azurerm_kubernetes_cluster]
}

# Configure the Azure Kubernetes Service User Assigned Managed Identity Federated Identity Credential for OIDC
module "azurerm_kubernetes_cluster_oidc_federated_identity_credential" {
  source                    = "../../modules/federated-identity-credential"
  name                      = lower("fc-aks-${local.resources_name_suffix}")
  user_assigned_identity_id = module.azurerm_user_assigned_identity_aks.user_assigned_identity_id
  issuer                    = module.azurerm_kubernetes_cluster.kubernetes_cluster_oidc_issuer_url
  subject                   = "system:serviceaccount:default:agic-controller-pr-sa-ingress-azure"
  audience                  = ["api://AzureADTokenExchange"]
  depends_on                = [module.azurerm_kubernetes_cluster, module.azurerm_user_assigned_identity_aks]
}

# Configure the Mutliple Kubernetes Namespace for the AKS Cluster
module "kubernetes_namespace_aks" {
  source     = "../../modules/kubernetes-namespace"
  for_each   = var.kubernetes_namespaces
  name       = each.value.name
  depends_on = [module.azurerm_kubernetes_cluster]
}

# Configure the Multiple Kubernetes Service Account for the AKS Cluster
module "kubernetes_service_account_aks" {
  source     = "../../modules/kubernetes-service-account"
  for_each   = var.kubernetes_service_accounts
  name       = each.value.name
  namespace  = each.value.namespace
  client_id  = "///"
  depends_on = [module.azurerm_kubernetes_cluster, module.kubernetes_namespace_aks]
}

# Configure the Helm Release for the AKS Cluster AGIC Controller
module "helm_release_aks_agic_controller" {
  source        = "../../modules/helm-release"
  name          = "agic-controller-${local.env}"
  namespace     = "default"
  repository    = "oci://mcr.microsoft.com/azure-application-gateway/charts"
  chart         = "ingress-azure"
  chart_version = "1.8.1"
  set_values = {
    appgw = {
      name           = module.azurerm_application_gateway.application_gateway_name
      resourceGroup  = module.azurerm_resource_group.resource_group_name
      subscriptionId = var.subscription_id
      usePrivateIP   = true
      shared         = false
    }
    armAuth = {
      type             = "workloadIdentity"
      identityClientID = module.azurerm_user_assigned_identity_aks.user_assigned_identity_client_id
    }
    rbac = {
      enabled = true
    }
    aksClusterConfiguration = {
      apiServerAddress = module.azurerm_kubernetes_cluster.kubernetes_cluster_host
    }
  }
  depends_on = [module.azurerm_kubernetes_cluster, module.azurerm_kubernetes_cluster_oidc_federated_identity_credential, module.azurerm_kubernetes_cluster_user_node_pool]
}

# Configure the Azure Kubernetes Service Azure Key Vault Secrets Provider Managed Identity Federated Identity Credential for OIDC
module "azurerm_kubernetes_cluster_keyvault_federated_identity_credential" {
  source                    = "../../modules/federated-identity-credential"
  for_each                  = var.kubernetes_service_accounts
  name                      = lower("fc-${each.value.name}")
  user_assigned_identity_id = "/subscriptions/${var.subscription_id}/resourceGroups/${module.azurerm_kubernetes_cluster.kubernetes_cluster_node_resource_group}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/azurekeyvaultsecretsprovider-${module.azurerm_kubernetes_cluster.kubernetes_cluster_name}"
  issuer                    = module.azurerm_kubernetes_cluster.kubernetes_cluster_oidc_issuer_url
  subject                   = "system:serviceaccount:${each.value.namespace}:${each.value.name}"
  audience                  = ["api://AzureADTokenExchange"]
  depends_on                = [module.azurerm_kubernetes_cluster, module.azurerm_user_assigned_identity_aks]
}
