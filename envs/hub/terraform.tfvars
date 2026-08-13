# Terraform Variables for the Hub Environment

# Subscription and Provider Configuration for the Hub Environment
subscription_id = "886e97b0-f259-4c79-8ac0-984dbc60bbee"
# Local variables for the Hub environment, including subscription and provider configuration, as well as environment-specific settings.
project_name = "xencia"
env          = "hub"
region_code  = "eus2"
region       = "canadacentral"
instance     = "001"
# End of Local variables for the Hub environment

# Variables for the Virtual Network in the Operations environment
ops_resource_group_name = "rg-gh-eus2-ops"
ops_vnet_name           = "vnet-gh-eus2-ops"
# End of virtual network configuration for the Operations environment

# Variables for the Virtual Network in the Hub environment
address_space = ["100.64.8.0/21"]
# End of virtual network configuration for the Hub environment

# Varibales for the Subnets in the Hub environment
subnets = {
  "GatewaySubnet" = {
    subnet_name                       = "GatewaySubnet"
    address_prefixes                  = ["100.64.8.0/24"]
    private_endpoint_network_policies = "RouteTableEnabled"
  },
  "AzureFirewallSubnet" = {
    subnet_name                       = "AzureFirewallSubnet"
    address_prefixes                  = ["100.64.9.0/24"]
    private_endpoint_network_policies = "RouteTableEnabled"
  },
  "AzureBastionSubnet" = {
    subnet_name                       = "AzureBastionSubnet"
    address_prefixes                  = ["100.64.10.0/24"]
    private_endpoint_network_policies = "RouteTableEnabled"
  },
  "VMSubnet" = {
    subnet_name                       = "vm"
    address_prefixes                  = ["100.64.12.0/24"]
    private_endpoint_network_policies = "RouteTableEnabled"
  }
}
# End of subnet configuration for the Hub environment


# Variables for the Virtual Network Peering between the Hub and Operations environments
hub_allow_virtual_network_access = true
hub_allow_forwarded_traffic      = true
hub_allow_gateway_transit        = true
hub_use_remote_gateways          = false
# End of virtual network peering configuration for the Hub environment

# Variables for the Virtual Network Peering between the Operations and Hub environments
ops_allow_virtual_network_access = true
ops_allow_forwarded_traffic      = true
ops_allow_gateway_transit        = false
ops_use_remote_gateways          = true
# End of virtual network peering configuration for the Operations environment



# Variables for Azure Windows Virtual Machine
windows_vm_name_suffix                        = "winsvc"
windows_vm_size                               = "Standard_D2as_v6"
windows_vm_admin_username                     = "winadmin"
windows_vm_private_ip_allocation_method       = "Dynamic"
windows_vm_private_ip_address                 = null
windows_vm_allowed_inbound_rules              = {}
windows_vm_os_disk_caching                    = "ReadWrite"
windows_vm_os_disk_storage_account_type       = "Premium_LRS"
windows_vm_os_disk_size_gb                    = 128
windows_vm_source_image_publisher             = "MicrosoftWindowsServer"
windows_vm_source_image_offer                 = "WindowsServer"
windows_vm_source_image_sku                   = "2022-datacenter-azure-edition"
windows_vm_source_image_version               = "latest"
windows_vm_encryption_at_host_enabled         = false
windows_vm_secure_boot_enabled                = true
windows_vm_vtpm_enabled                       = true
windows_vm_patch_mode                         = "AutomaticByPlatform"
windows_vm_enable_monitoring_extension        = true
windows_vm_enable_guest_configuration         = true
windows_vm_bastion_login_principal_ids        = []
windows_vm_bastion_login_role_definition_name = "Virtual Machine User Login"
# End of variables for Azure Windows Virtual Machine

# Variables for the Azure Firewall module
firewall_sku_name                 = "AZFW_VNet"
firewall_sku_tier                 = "Premium"
firewall_intrusion_detection_mode = "Deny"
# End of variables for the Azure Firewall module

# Variables for the Azure Virtual Network Gateway module
vpn_gateway_type                         = "Vpn"
vpn_gateway_vpn_type                     = "RouteBased"
vpn_gateway_active_active                = false
vpn_gateway_sku                          = "VpnGw1AZ"
vpn_gateway_bgp_enabled                  = false
vpn_gateway_private_ip_allocation_method = "Dynamic"
# End of variables for the Azure Virtual Network Gateway module



