# Subscription and Provider Configuration for the Hub Environment
variable "subscription_id" {
  description = "The Azure subscription ID to deploy resources into."
  type        = string
}
# End of subscription and provider configuration for the Hub environment

# Local Configuration for the Hub Environment
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

# End of local configuration for the Hub environment


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

# Variables for the Virtual Network Peering between the Operations and Hub environments
variable "ops_allow_virtual_network_access" {
  description = "Whether to allow virtual network access between the Operations and Hub environments."
  type        = bool
}

variable "ops_allow_forwarded_traffic" {
  description = "Whether to allow forwarded traffic from the Hub environment to the Operations environment."
  type        = bool
}

variable "ops_allow_gateway_transit" {
  description = "Whether to allow gateway transit between the Operations and Hub environments."
  type        = bool
}

variable "ops_use_remote_gateways" {
  description = "Whether to use remote gateways for the peering from the Operations environment to the Hub environment."
  type        = bool
}
# End of variables for the Virtual Network Peering between the Operations and Hub environments

# Varibales for the Virtual Network in the Hub environment
variable "address_space" {
  description = "The address space for the Virtual Network."
  type        = list(string)
}
# End of variables for the Virtual Network in the Hub environment

# Variables for the Virtual Network Peering between the Hub and Operations environments
variable "hub_allow_virtual_network_access" {
  description = "Whether to allow virtual network access between the Hub and Operations environments."
  type        = bool
}

variable "hub_allow_forwarded_traffic" {
  description = "Whether to allow forwarded traffic from the Operations environment to the Hub environment."
  type        = bool
}

variable "hub_allow_gateway_transit" {
  description = "Whether to allow gateway transit between the Hub and Operations environments."
  type        = bool
}

variable "hub_use_remote_gateways" {
  description = "Whether to use remote gateways for the peering from the Hub environment to the Operations environment."
  type        = bool
}
# End of variables for the Virtual Network Peering between the Hub and Operations environments

# Variables for Azure Subnet module
variable "subnets" {
  description = "A map of subnets to create within the Virtual Network"
  type = map(object({
    subnet_name                       = string
    address_prefixes                  = list(string)
    service_endpoints                 = optional(list(string))
    private_endpoint_network_policies = optional(string)
    delegation_name                   = optional(string)
    delegation_service_name           = optional(string)
    delegation_actions                = optional(list(string))
  }))
}
# End of variables for Azure Subnet module

# Variables for the Azure Windows Virtual Machine module
variable "windows_vm_name_suffix" {
  description = "The suffix used in the Windows VM name."
  type        = string
  default     = "win"
}

variable "windows_vm_size" {
  description = "The Windows VM size."
  type        = string
  default     = "Standard_D2as_v5"
}

variable "windows_vm_admin_username" {
  description = "The Windows VM local administrator username."
  type        = string
  default     = "azureadmin"
}

variable "windows_vm_private_ip_allocation_method" {
  description = "The Windows VM private IP allocation method."
  type        = string
  default     = "Dynamic"
}

variable "windows_vm_private_ip_address" {
  description = "The Windows VM static private IP address. Required when allocation method is Static."
  type        = string
  default     = null
}

variable "windows_vm_allowed_inbound_rules" {
  description = "Optional inbound allow rules for the Windows VM NIC NSG. Leave empty to deny VNet inbound access."
  type = map(object({
    priority                = number
    protocol                = string
    destination_port_ranges = list(string)
    source_address_prefixes = list(string)
  }))
  default = {}
}

variable "windows_vm_os_disk_caching" {
  description = "The Windows VM OS disk caching mode."
  type        = string
  default     = "ReadWrite"
}

variable "windows_vm_os_disk_storage_account_type" {
  description = "The Windows VM OS disk storage account type."
  type        = string
  default     = "Premium_LRS"
}

variable "windows_vm_os_disk_size_gb" {
  description = "The Windows VM OS disk size in GB."
  type        = number
  default     = 128
}

variable "windows_vm_source_image_publisher" {
  description = "The Windows VM source image publisher."
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "windows_vm_source_image_offer" {
  description = "The Windows VM source image offer."
  type        = string
  default     = "WindowsServer"
}

variable "windows_vm_source_image_sku" {
  description = "The Windows VM source image SKU."
  type        = string
  default     = "2022-datacenter-azure-edition"
}

variable "windows_vm_source_image_version" {
  description = "The Windows VM source image version."
  type        = string
  default     = "latest"
}

variable "windows_vm_encryption_at_host_enabled" {
  description = "Whether encryption at host is enabled for the Windows VM."
  type        = bool
  default     = true
}

variable "windows_vm_secure_boot_enabled" {
  description = "Whether secure boot is enabled for the Windows VM."
  type        = bool
  default     = true
}

variable "windows_vm_vtpm_enabled" {
  description = "Whether vTPM is enabled for the Windows VM."
  type        = bool
  default     = true
}

variable "windows_vm_patch_mode" {
  description = "The Windows VM patch mode."
  type        = string
  default     = "AutomaticByPlatform"
}

variable "windows_vm_enable_monitoring_extension" {
  description = "Whether Azure Monitor Agent is installed on the Windows VM."
  type        = bool
  default     = true
}

variable "windows_vm_enable_guest_configuration" {
  description = "Whether Guest Configuration is installed on the Windows VM."
  type        = bool
  default     = true
}

variable "windows_vm_bastion_login_principal_ids" {
  description = "Microsoft Entra principal object IDs to grant Azure RBAC login access to the Windows VM through Bastion."
  type        = list(string)
  default     = []
}

variable "windows_vm_bastion_login_role_definition_name" {
  description = "The Azure RBAC role assigned on the Windows VM for Bastion login. Use Virtual Machine User Login or Virtual Machine Administrator Login."
  type        = string
  default     = "Virtual Machine User Login"
}
# End of variables for the Azure Windows Virtual Machine module


# Variables for the Azure Firewall module
variable "firewall_sku_name" {
  description = "The SKU name of the Azure Firewall (e.g., 'AZFW_VNet')."
  type        = string
}

variable "firewall_sku_tier" {
  description = "The SKU tier of the Azure Firewall (e.g., 'Standard', 'Premium')."
  type        = string
}

variable "firewall_intrusion_detection_mode" {
  description = "The mode for intrusion detection on the Azure Firewall. Valid values are 'Alert' and 'Deny'."
  type        = string
  default     = "Deny"
}
# End of variables for the Azure Firewall module

# Variables for the Azure VPN Gateway module
variable "vpn_gateway_type" {
  description = "The type of the Azure VPN Gateway (e.g., 'Vpn', 'ExpressRoute')."
  type        = string
}

variable "vpn_gateway_vpn_type" {
  description = "The VPN type of the Azure VPN Gateway (e.g., 'RouteBased', 'PolicyBased')."
  type        = string
}

variable "vpn_gateway_active_active" {
  description = "Whether the Azure VPN Gateway is active-active (only applicable for RouteBased VPN Gateways)."
  type        = bool
}

variable "vpn_gateway_sku" {
  description = "The SKU of the Azure VPN Gateway (e.g., 'Basic', 'VpnGw1', 'VpnGw2', 'VpnGw3', 'VpnGw4', 'VpnGw5')."
  type        = string
}

variable "vpn_gateway_private_ip_allocation_method" {
  description = "The allocation method for the private IP address of the Azure VPN Gateway (e.g., 'Dynamic', 'Static')."
  type        = string
}

variable "vpn_gateway_bgp_enabled" {
  description = "Whether to enable BGP for the Azure VPN Gateway."
  type        = bool  
}
# End of variables for the Azure VPN Gateway module

