# Main Modules Configuration for the Hub Environment

# Configure the Azure Resource Group
module "azurerm_resource_group" {
  source   = "../../modules/resource-group"
  name     = lower("rg-${local.resources_name_suffix}")
  location = local.region
  tags     = merge(local.common_tags, { ROLE = "RESOURCEGROUP" })
}

# Configure the Azure Virtual Network
module "azurerm_virtual_network" {
  source              = "../../modules/virtual-network"
  name                = lower("vnet-${local.resources_name_suffix}")
  location            = local.region
  resource_group_name = module.azurerm_resource_group.resource_group_name
  address_space       = var.address_space
  tags                = merge(local.common_tags, { ROLE = "VIRTUALNETWORK" })
  depends_on          = [module.azurerm_resource_group]
}

# Configure the Azure Subnet
module "azurerm_subnet" {
  source                            = "../../modules/subnet"
  for_each                          = var.subnets
  name                              = contains(["GatewaySubnet", "AzureFirewallSubnet", "AzureBastionSubnet"], each.value.subnet_name) ? each.value.subnet_name : lower("snet-${each.value.subnet_name}-${local.env}-${local.region_code}-${local.instance}")
  resource_group_name               = module.azurerm_resource_group.resource_group_name
  virtual_network_name              = module.azurerm_virtual_network.name
  address_prefixes                  = each.value.address_prefixes
  private_endpoint_network_policies = each.value.private_endpoint_network_policies
  delegation_name                   = lookup(each.value, "delegation_name", null)
  delegation_service_name           = lookup(each.value, "delegation_service_name", null)
  delegation_actions                = lookup(each.value, "delegation_actions", null)
  service_endpoints                 = lookup(each.value, "service_endpoints", null)
  location                          = local.region
  tags                              = merge(local.common_tags, { ROLE = "SUBNET" })
  depends_on                        = [module.azurerm_virtual_network]
}






# Configure the Azure Bastion Host Public IP Address
module "azurerm_public_ip_bastion" {
  source               = "../../modules/public-ip-address"
  name                 = lower("pip-bastion-${local.resources_name_suffix}")
  location             = local.region
  resource_group_name  = module.azurerm_resource_group.resource_group_name
  allocation_method    = "Static"
  sku                  = "Standard"
  zones                = ["1", "2", "3"]
  ddos_protection_mode = "Disabled"
  tags                 = merge(local.common_tags, { ROLE = "BASTIONHOST" })
  depends_on           = [module.azurerm_resource_group]
}

# Configure the Azure Bation Host
module "azurerm_bastion_host" {
  source               = "../../modules/bastion-host"
  name                 = lower("bas-${local.resources_name_suffix}")
  location             = local.region
  resource_group_name  = module.azurerm_resource_group.resource_group_name
  public_ip_address_id = module.azurerm_public_ip_bastion.public_ip_address_id
  subnet_id            = module.azurerm_subnet["AzureBastionSubnet"].id
  tags                 = merge(local.common_tags, { ROLE = "BASTIONHOST" })
  depends_on           = [module.azurerm_virtual_network]
}


# Generate the Azure Windows Virtual Machine local administrator password
resource "random_password" "windows_virtual_machine_admin_password" {
  length           = 16
  special          = true
  min_lower        = 6
  min_upper        = 5
  min_numeric      = 4
  min_special      = 1
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Configure the PCI-aligned Azure Windows Virtual Machine
module "azurerm_windows_virtual_machine" {
  source                       = "../../modules/windows-virtual-machine"
  name                         = lower("vm-${var.windows_vm_name_suffix}-${local.resources_name_suffix}")
  resource_group_name          = module.azurerm_resource_group.resource_group_name
  location                     = local.region
  size                         = var.windows_vm_size
  admin_username               = var.windows_vm_admin_username
  admin_password               = random_password.windows_virtual_machine_admin_password.result
  subnet_id                    = module.azurerm_subnet["VMSubnet"].id
  private_ip_allocation_method = var.windows_vm_private_ip_allocation_method
  private_ip_address           = var.windows_vm_private_ip_address
  allow_public_access          = false
  allowed_inbound_rules = merge(var.windows_vm_allowed_inbound_rules, {
    "Allow-Hub-Bastion-RDP" = {
      priority                = 100
      protocol                = "Tcp"
      destination_port_ranges = ["3389"]
      source_address_prefixes = [var.subnets["AzureBastionSubnet"].address_prefixes[0]]
    }
  })
  os_disk_caching              = var.windows_vm_os_disk_caching
  os_disk_storage_account_type = var.windows_vm_os_disk_storage_account_type
  os_disk_size_gb              = var.windows_vm_os_disk_size_gb
  enable_disk_encryption       = false
  source_image_publisher       = var.windows_vm_source_image_publisher
  source_image_offer           = var.windows_vm_source_image_offer
  source_image_sku             = var.windows_vm_source_image_sku
  source_image_version         = var.windows_vm_source_image_version
  encryption_at_host_enabled   = var.windows_vm_encryption_at_host_enabled
  secure_boot_enabled          = var.windows_vm_secure_boot_enabled
  vtpm_enabled                 = var.windows_vm_vtpm_enabled
  patch_mode                   = var.windows_vm_patch_mode
  enable_monitoring_extension  = var.windows_vm_enable_monitoring_extension
  enable_guest_configuration   = var.windows_vm_enable_guest_configuration
  tags                         = merge(local.common_tags, { ROLE = "WINDOWSVM" })
  depends_on                   = [module.azurerm_subnet]
}

# Configure Azure RBAC login access for Windows VM through Hub Bastion
module "azurerm_role_assignment_windows_vm_bastion_login" {
  source               = "../../modules/rbac"
  for_each             = toset(var.windows_vm_bastion_login_principal_ids)
  scope                = module.azurerm_windows_virtual_machine.windows_virtual_machine_id
  role_definition_name = var.windows_vm_bastion_login_role_definition_name
  principal_id         = each.value
  depends_on           = [module.azurerm_windows_virtual_machine]
}


# Configure the Azure Public IP Address for the Azure Firewall
module "azurerm_public_ip_firewall" {
  source               = "../../modules/public-ip-address"
  name                 = lower("pip-fw-${local.resources_name_suffix}")
  location             = local.region
  resource_group_name  = module.azurerm_resource_group.resource_group_name
  allocation_method    = "Static"
  sku                  = "Standard"
  zones                = ["1", "2", "3"]
  ddos_protection_mode = "Disabled"
  tags                 = merge(local.common_tags, { ROLE = "FIREWALL" })
  depends_on           = [module.azurerm_resource_group]
}

# Configure the Azure Firewall
module "azurerm_firewall" {
  source                = "../../modules/firewall"
  name                  = lower("afw-${local.resources_name_suffix}")
  location              = local.region
  resource_group_name   = module.azurerm_resource_group.resource_group_name
  public_ip_address_id  = module.azurerm_public_ip_firewall.public_ip_address_id
  subnet_id             = module.azurerm_subnet["AzureFirewallSubnet"].id
  sku_name              = var.firewall_sku_name
  sku_tier              = var.firewall_sku_tier
  firewall_policy_id    = module.azurerm_firewall_policy.firewall_policy_id
  ip_configuration_name = lower("ipconfig-afw-${local.resources_name_suffix}")
  tags                  = merge(local.common_tags, { ROLE = "FIREWALL" })
  depends_on            = [module.azurerm_subnet, module.azurerm_public_ip_firewall, module.azurerm_firewall_policy]
}

# Configure the Azure Firewall Policy
module "azurerm_firewall_policy" {
  source                   = "../../modules/firewall-policy"
  name                     = lower("afwp-${local.resources_name_suffix}")
  location                 = local.region
  resource_group_name      = module.azurerm_resource_group.resource_group_name
  sku                      = "Premium"
  intrusion_detection_mode = var.firewall_intrusion_detection_mode
  # log_analytics_retention_in_days = 30
  # log_analytics_workspace_id      = module.azurerm_log_analytics_workspace.log_analytics_workspace_resource_id
  tags       = merge(local.common_tags, { ROLE = "FIREWALLPOLICY" })
  depends_on = [module.azurerm_resource_group]
}

# Configure the Azure Public IP Address for the Azure Virtual Network Gateway
module "azurerm_public_ip_vnet_gateway" {
  source               = "../../modules/public-ip-address"
  name                 = lower("pip-vng-${local.resources_name_suffix}")
  location             = local.region
  resource_group_name  = module.azurerm_resource_group.resource_group_name
  allocation_method    = "Static"
  sku                  = "Standard"
  zones                = ["1", "2", "3"]
  ddos_protection_mode = "Disabled"
  tags                 = merge(local.common_tags, { ROLE = "VIRTUALNETWORKGATEWAY" })
  depends_on           = [module.azurerm_resource_group]
}

# Configure the Azure Virtual Network Gateway
module "azurerm_virtual_network_gateway" {
  source                        = "../../modules/vpn-gateway"
  name                          = lower("vgw-${local.resources_name_suffix}")
  location                      = local.region
  resource_group_name           = module.azurerm_resource_group.resource_group_name
  type                          = var.vpn_gateway_type
  vpn_type                      = var.vpn_gateway_vpn_type
  active_active                 = var.vpn_gateway_active_active
  sku                           = var.vpn_gateway_sku
  ip_configuration_name         = lower("ipconfig-vng-${local.resources_name_suffix}")
  public_ip_address_id          = module.azurerm_public_ip_vnet_gateway.public_ip_address_id
  private_ip_address_allocation = var.vpn_gateway_private_ip_allocation_method
  subnet_id                     = module.azurerm_subnet["GatewaySubnet"].id
  bgp_enabled                   = var.vpn_gateway_bgp_enabled
  tags                          = merge(local.common_tags, { ROLE = "VIRTUALNETWORKGATEWAY" })
  depends_on                    = [module.azurerm_subnet, module.azurerm_public_ip_vnet_gateway]
}

# Configure the Azure Virtual Network Peering between the Operations and Hub Virtual Networks
module "azurerm_virtual_network_peering_ops_to_hub" {
  source                       = "../../modules/virtual-network-peering"
  name                         = lower("${data.azurerm_virtual_network.operations_vnet.name}-to-${module.azurerm_virtual_network.name}")
  resource_group_name          = data.azurerm_virtual_network.operations_vnet.resource_group_name
  virtual_network_name         = data.azurerm_virtual_network.operations_vnet.name
  remote_virtual_network_id    = module.azurerm_virtual_network.id
  allow_virtual_network_access = var.ops_allow_virtual_network_access
  allow_forwarded_traffic      = var.ops_allow_forwarded_traffic
  allow_gateway_transit        = var.ops_allow_gateway_transit
  use_remote_gateways          = var.ops_use_remote_gateways
  depends_on                   = [module.azurerm_virtual_network, module.azurerm_subnet, data.azurerm_virtual_network.operations_vnet, module.azurerm_virtual_network_gateway]
}

# Configure the Azure Virtual Network Peering between the Hub and Operations Virtual Networks
module "azurerm_virtual_network_peering_hub_to_ops" {
  source                       = "../../modules/virtual-network-peering"
  name                         = lower("${module.azurerm_virtual_network.name}-to-${data.azurerm_virtual_network.operations_vnet.name}")
  resource_group_name          = module.azurerm_resource_group.resource_group_name
  virtual_network_name         = module.azurerm_virtual_network.name
  remote_virtual_network_id    = data.azurerm_virtual_network.operations_vnet.id
  allow_virtual_network_access = var.hub_allow_virtual_network_access
  allow_forwarded_traffic      = var.hub_allow_forwarded_traffic
  allow_gateway_transit        = var.hub_allow_gateway_transit
  use_remote_gateways          = var.hub_use_remote_gateways
  depends_on                   = [module.azurerm_virtual_network, module.azurerm_subnet, data.azurerm_virtual_network.operations_vnet, module.azurerm_virtual_network_peering_ops_to_hub]
}
