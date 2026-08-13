# Azure Firewall Module

This Terraform module creates an Azure Firewall with configurable SKU tiers, IP configuration, and optional diagnostic logging for network security and traffic management.

## Description

Azure Firewall is a managed, cloud-based network security service that protects Azure Virtual Network resources. This module simplifies the deployment of Azure Firewall with support for both Standard and Premium tiers, VNet and Hub SKU options, and optional Log Analytics integration for centralized monitoring.

## Features

- ✅ Support for Standard and Premium SKU tiers
- ✅ VNet and Hub SKU options
- ✅ Configurable IP configuration with public IP
- ✅ Optional Log Analytics diagnostic integration
- ✅ Centralized network traffic management
- ✅ Application and network rule support
- ✅ IDPS (Intrusion Detection and Prevention System) - Premium tier
- ✅ URL filtering and threat intelligence
- ✅ Comprehensive tagging support
- ✅ High availability and scalability
- ✅ DDoS protection included

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0 |

## Resources Created

| Resource Type | Description | Conditionally Created |
|--------------|-------------|----------------------|
| `azurerm_firewall` | The Azure Firewall resource | Always |
| `azurerm_monitor_diagnostic_setting` | Diagnostic setting for Log Analytics | If `enable_diagnostic = true` |

## Prerequisites

Before using this module, you must have:

1. **Virtual Network** with a dedicated subnet
   - Subnet name must be `AzureFirewallSubnet`
   - Minimum subnet size: /26 (64 addresses)
   - Recommended: /24 or larger for scalability

2. **Public IP Address**
   - Must be Standard SKU (not Basic)
   - Static allocation method
   - Must be in the same region as the firewall

3. **Log Analytics Workspace** (if diagnostics enabled)
   - For centralized logging and monitoring
   - Must be in the same or accessible region

## Usage

### Basic Azure Firewall (Standard Tier)

```hcl
module "azure_firewall" {
  source = "./modules/firewall"
  
  name                = "fw-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  
  ip_configuration_name    = "fw-ipconfig"
  subnet_id                = module.firewall_subnet.id
  public_ip_address_id     = azurerm_public_ip.fw_pip.id
  
  enable_diagnostic = false
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Create Public IP for Firewall
resource "azurerm_public_ip" "fw_pip" {
  name                = "pip-fw-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Premium Firewall with Diagnostics

```hcl
module "azure_firewall_premium" {
  source = "./modules/firewall"
  
  name                = "fw-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  
  sku_name = "AZFW_VNet"
  sku_tier = "Premium"  # Advanced threat protection
  
  ip_configuration_name    = "fw-ipconfig"
  subnet_id                = module.firewall_subnet.id
  public_ip_address_id     = azurerm_public_ip.fw_pip.id
  
  # Enable diagnostics for monitoring
  enable_diagnostic           = true
  log_analytics_workspace_id  = module.log_analytics.id
  
  tags = {
    Environment = "Production"
    Tier        = "Premium"
    ManagedBy   = "Terraform"
  }
}

# Create Public IP
resource "azurerm_public_ip" "fw_pip" {
  name                = "pip-fw-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Log Analytics for diagnostics
module "log_analytics" {
  source = "./modules/log-analytics-workspaces"
  
  name                = "law-firewall-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  
  tags = {
    Environment = "Production"
  }
}
```

### Complete Hub and Spoke Deployment

```hcl
locals {
  common_tags = {
    Environment = "Production"
    Project     = "IncumbentFI"
    ManagedBy   = "Terraform"
  }
}

# Resource Group
module "resource_group" {
  source = "./modules/resource-group"
  
  name     = "rg-hub-prod-eastus-001"
  location = "eastus"
  tags     = local.common_tags
}

# Hub Virtual Network
module "hub_vnet" {
  source = "./modules/virtual-network"
  
  name                = "vnet-hub-prod-eastus-001"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  
  tags = local.common_tags
}

# AzureFirewallSubnet (required for firewall)
module "firewall_subnet" {
  source = "./modules/subnet"
  
  name                = "AzureFirewallSubnet"
  resource_group_name = module.resource_group.resource_group_name
  vnet_name           = module.hub_vnet.name
  address_prefixes    = ["10.0.1.0/24"]  # Minimum /26
  
  depends_on = [module.hub_vnet]
}

# Additional subnet for management
module "management_subnet" {
  source = "./modules/subnet"
  
  name                = "subnet-management-prod"
  resource_group_name = module.resource_group.resource_group_name
  vnet_name           = module.hub_vnet.name
  address_prefixes    = ["10.0.2.0/24"]
}

# Public IP for Firewall
resource "azurerm_public_ip" "fw_pip" {
  name                = "pip-fw-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]  # Zone redundant
  
  tags = local.common_tags
}

# Log Analytics Workspace
module "log_analytics" {
  source = "./modules/log-analytics-workspaces"
  
  name                = "law-firewall-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  
  tags = local.common_tags
}

# Azure Firewall
module "azure_firewall" {
  source = "./modules/firewall"
  
  name                = "fw-hub-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  
  sku_name = "AZFW_VNet"
  sku_tier = "Premium"
  
  ip_configuration_name   = "fw-ipconfig-001"
  subnet_id               = module.firewall_subnet.id
  public_ip_address_id    = azurerm_public_ip.fw_pip.id
  
  enable_diagnostic           = true
  log_analytics_workspace_id  = module.log_analytics.id
  
  tags = local.common_tags
  
  depends_on = [
    module.firewall_subnet,
    azurerm_public_ip.fw_pip
  ]
}

# Route Table for directing traffic to firewall
resource "azurerm_route_table" "fw_route_table" {
  name                = "rt-fw-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  
  tags = local.common_tags
}

# Default route through firewall
resource "azurerm_route" "default_route" {
  name                   = "route-default-to-firewall"
  resource_group_name    = module.resource_group.resource_group_name
  route_table_name       = azurerm_route_table.fw_route_table.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.azure_firewall.firewall_private_ip
}

# Associate route table with subnets
resource "azurerm_subnet_route_table_association" "management_rt_assoc" {
  subnet_id      = module.management_subnet.id
  route_table_id = azurerm_route_table.fw_route_table.id
}

output "firewall_id" {
  value = module.azure_firewall.firewall_id
}

output "firewall_private_ip" {
  value = module.azure_firewall.firewall_private_ip
}

output "firewall_public_ip" {
  value = azurerm_public_ip.fw_pip.ip_address
}
```

### Firewall with Application Rules

```hcl
# Azure Firewall
module "azure_firewall" {
  source = "./modules/firewall"
  
  name                = "fw-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  
  sku_name = "AZFW_VNet"
  sku_tier = "Standard"
  
  ip_configuration_name    = "fw-ipconfig"
  subnet_id                = module.firewall_subnet.id
  public_ip_address_id     = azurerm_public_ip.fw_pip.id
  
  tags = {
    Environment = "Production"
  }
}

# Application Rule Collection
resource "azurerm_firewall_application_rule_collection" "example" {
  name                = "app-rules-001"
  azure_firewall_name = module.azure_firewall.firewall_name
  resource_group_name = module.resource_group.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name             = "allow-microsoft"
    source_addresses = ["10.0.0.0/8"]
    target_fqdns     = ["*.microsoft.com"]
    protocol {
      port = "443"
      type = "Https"
    }
  }
}

# Network Rule Collection
resource "azurerm_firewall_network_rule_collection" "example" {
  name                = "network-rules-001"
  azure_firewall_name = module.azure_firewall.firewall_name
  resource_group_name = module.resource_group.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name                  = "allow-dns"
    source_addresses      = ["10.0.0.0/8"]
    destination_ports     = ["53"]
    destination_addresses = ["*"]
    protocols             = ["UDP"]
  }
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | The name of the Azure Firewall | `string` | Yes | n/a |
| location | The Azure region for the firewall | `string` | Yes | n/a |
| resource_group_name | The name of the resource group | `string` | Yes | n/a |
| sku_name | The SKU name: AZFW_VNet or AZFW_Hub | `string` | Yes | n/a |
| sku_tier | The SKU tier: Standard or Premium | `string` | Yes | n/a |
| ip_configuration_name | The name of the IP configuration | `string` | Yes | n/a |
| subnet_id | The ID of the AzureFirewallSubnet | `string` | Yes | n/a |
| public_ip_address_id | The ID of the public IP address | `string` | Yes | n/a |
| enable_diagnostic | Enable diagnostic settings for Log Analytics | `bool` | No | `false` |
| log_analytics_workspace_id | The ID of the Log Analytics workspace | `string` | No | n/a |
| tags | Tags to assign to resources | `map(string)` | No | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| firewall_id | The ID of the Azure Firewall |
| firewall_name | The name of the Azure Firewall |
| firewall_resource_group_name | The resource group name |
| firewall_location | The location of the firewall |
| firewall_private_ip | The private IP address of the firewall |
| firewall_public_ip_id | The ID of the associated public IP |

## SKU Comparison

### Standard Tier

**Features:**
- ✅ Stateful packet filtering
- ✅ Network and Application rules
- ✅ URL filtering
- ✅ Threat intelligence
- ✅ SNAT/DNAT support
- ✅ Service tags
- ❌ IDPS not available
- ❌ TLS inspection not available

**Best for:** General network filtering and traffic management

**Cost:** Lower cost

### Premium Tier

**Features:**
- ✅ All Standard features
- ✅ IDPS (Intrusion Detection/Prevention)
- ✅ TLS inspection
- ✅ Web categorization (advanced)
- ✅ Certificate-based authentication
- ✅ Geo-filtering
- ✅ Zero-trust capability
- ✅ Outbound IDPS

**Best for:** Enterprise with advanced security requirements and compliance needs

**Cost:** Higher cost but includes advanced threat protection

## SKU Names

### AZFW_VNet (Virtual Network)

- Standard option for Virtual Networks
- Used in hub-and-spoke architectures
- Single IP configuration
- Supported in all Azure regions

### AZFW_Hub (Firewall Manager)

- Used with Azure Firewall Manager
- For managing multiple firewalls centrally
- Multi-region deployment support
- Advanced policy management

## Subnet Requirements

### AzureFirewallSubnet

The firewall **must** be deployed in a subnet with these exact specifications:

```hcl
resource "azurerm_subnet" "firewall_subnet" {
  name                = "AzureFirewallSubnet"  # Case-sensitive, exact name
  resource_group_name = module.resource_group.resource_group_name
  virtual_network_name = module.vnet.name
  address_prefixes    = ["10.0.1.0/24"]  # Minimum /26, recommended /24 or /23
}
```

**Important:**
- Subnet name is case-sensitive and must be exactly `AzureFirewallSubnet`
- Minimum size: /26 (64 addresses)
- Recommended: /24 (256 addresses) or /23 (512 addresses)
- Cannot have any NSGs or other resources
- Cannot be delegated to any service

## Public IP Requirements

```hcl
resource "azurerm_public_ip" "firewall_pip" {
  name                = "pip-firewall-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  allocation_method   = "Static"      # Must be Static
  sku                 = "Standard"    # Must be Standard (not Basic)
  zones               = ["1", "2", "3"]  # Optional but recommended for HA
}
```

**Requirements:**
- Must be Standard SKU (not Basic)
- Must use Static allocation
- Must be in the same region as firewall
- Zone-redundant deployment recommended for production

## Routing Configuration

To use the firewall for traffic management, configure User Defined Routes (UDR):

```hcl
# Create route table
resource "azurerm_route_table" "firewall_routes" {
  name                = "rt-firewall-prod"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
}

# Default route through firewall
resource "azurerm_route" "default_route" {
  name                   = "route-0-0-0-0"
  resource_group_name    = module.resource_group.resource_group_name
  route_table_name       = azurerm_route_table.firewall_routes.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.azure_firewall.firewall_private_ip
}

# Associate with subnet
resource "azurerm_subnet_route_table_association" "example" {
  subnet_id      = azurerm_subnet.example.id
  route_table_id = azurerm_route_table.firewall_routes.id
}
```

## Firewall Rules

### Network Rules

Control traffic based on IP protocol, source/destination addresses, and ports:

```hcl
resource "azurerm_firewall_network_rule_collection" "example" {
  name                = "network-rules"
  azure_firewall_name = module.azure_firewall.firewall_name
  resource_group_name = module.resource_group.resource_group_name
  priority            = 100
  action              = "Allow"  # Allow or Deny

  rule {
    name                  = "allow-dns"
    source_addresses      = ["10.0.0.0/8"]
    destination_ports     = ["53"]
    destination_addresses = ["*"]
    protocols             = ["UDP", "TCP"]
  }
}
```

### Application Rules

Control traffic based on fully qualified domain names (FQDNs):

```hcl
resource "azurerm_firewall_application_rule_collection" "example" {
  name                = "application-rules"
  azure_firewall_name = module.azure_firewall.firewall_name
  resource_group_name = module.resource_group.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name             = "allow-azure"
    source_addresses = ["10.0.0.0/8"]
    target_fqdns     = ["*.azure.com", "*.microsoft.com"]
    protocol {
      type = "Https"
      port = "443"
    }
  }
}
```

### NAT Rules

Perform source/destination network address translation:

```hcl
resource "azurerm_firewall_nat_rule_collection" "example" {
  name                = "nat-rules"
  azure_firewall_name = module.azure_firewall.firewall_name
  resource_group_name = module.resource_group.resource_group_name
  priority            = 100
  action              = "Dnat"

  rule {
    name                = "translate-http"
    protocols           = ["TCP"]
    source_addresses    = ["*"]
    destination_address = azurerm_public_ip.firewall_pip.ip_address
    destination_ports   = ["80"]
    translated_address  = "10.0.1.20"
    translated_port     = "80"
  }
}
```

## Monitoring and Diagnostics

### Enable Diagnostic Logging

```hcl
module "azure_firewall" {
  source = "./modules/firewall"
  
  # ... other configuration ...
  
  enable_diagnostic           = true
  log_analytics_workspace_id  = module.log_analytics.id
}
```

### Log Categories

When diagnostics are enabled, the following logs are collected:

- **AzureFirewallApplicationRule** - Application rule processing logs
- **AzureFirewallNetworkRule** - Network rule processing logs
- **AzureFirewallDnsProxy** - DNS proxy operations
- **AzureFirewallThreatIntelLog** - Threat intelligence matches (Premium)
- **AzureFirewallIdpsSignature** - IDPS signature detections (Premium)

### Querying Logs in Log Analytics

```kusto
AzureDiagnostics
| where ResourceType == "AZUREFIREWALLS"
| where Category == "AzureFirewallApplicationRule"
| summarize count() by Action, Rule = msg_s
```

## Naming Conventions

When naming Azure Firewalls, follow [Azure naming conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming):

- **Length**: 1-80 characters
- **Valid characters**: Alphanumerics, underscores, periods, and hyphens
- **Start with**: Alphanumeric
- **End with**: Alphanumeric or underscore
- **Recommended pattern**: `fw-<application>-<environment>-<region>-<instance>`

### Examples

- `fw-hub-prod-eastus-001` - Hub firewall in production
- `fw-apps-prod-westus-001` - Application firewall in production
- `fw-dev-eastus-001` - Development firewall

## Security Best Practices

1. **Zone Redundancy**: Deploy public IP with zones for HA
2. **Premium Tier**: Use Premium for production with threat protection
3. **Centralized Management**: Use Azure Firewall Manager for multiple firewalls
4. **Regular Rule Review**: Audit and update rules regularly
5. **Logging**: Enable diagnostic logging to Log Analytics
6. **Threat Intelligence**: Use threat intelligence for advanced filtering
7. **TLS Inspection**: Enable TLS inspection for HTTPS traffic (Premium)
8. **IDPS**: Enable IDPS for intrusion detection (Premium)
9. **Azure Policy**: Enforce firewall policies organization-wide
10. **Monitoring**: Set up alerts for blocked traffic and security events

## Troubleshooting

### Common Issues

**Issue**: Firewall deployment fails with subnet error
- **Solution**:
  1. Verify subnet name is exactly `AzureFirewallSubnet` (case-sensitive)
  2. Ensure subnet size is minimum /26 (64 addresses)
  3. Confirm no NSGs are attached to the subnet

**Issue**: Public IP association fails
- **Solution**:
  1. Verify public IP is Standard SKU (not Basic)
  2. Ensure public IP uses Static allocation
  3. Confirm public IP is in same region as firewall

**Issue**: Traffic not passing through firewall
- **Solution**:
  1. Verify route table has default route (0.0.0.0/0) to firewall
  2. Check route table is associated with correct subnets
  3. Ensure firewall network rules allow the traffic
  4. Verify firewall has public outbound connectivity

**Issue**: Diagnostic logging not working
- **Solution**:
  1. Verify `enable_diagnostic = true`
  2. Confirm `log_analytics_workspace_id` is valid
  3. Check firewall managed identity has Log Analytics permissions

### Validation Commands

```powershell
# Show firewall configuration
az network firewall show --name fw-prod-eastus-001 \
  --resource-group rg-prod-001 --output table

# List firewall rules
az network firewall network-rule list \
  --firewall-name fw-prod-eastus-001 \
  --resource-group rg-prod-001

# Get firewall private IP
az network firewall show --name fw-prod-eastus-001 \
  --resource-group rg-prod-001 \
  --query "ipConfigurations[0].privateIpAddress"

# Test firewall reachability
az network firewall show --name fw-prod-eastus-001 \
  --resource-group rg-prod-001 \
  --query "properties.provisioningState"

# Terraform validation
terraform validate
terraform plan
```

## Module Validation

### Pre-deployment Checklist

```powershell
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment
terraform plan

# Format code
terraform fmt -recursive

# Security scan
terrascan scan -d ./modules/firewall -i terraform

# Lint check
tflint --init
tflint
```

## Notes

- **Subnet Requirement**: Azure Firewall MUST be in a subnet named exactly `AzureFirewallSubnet`
- **Regional Deployment**: Firewall and all resources must be in the same region
- **Public IP Required**: Firewall requires a Standard SKU public IP address
- **SKU Immutable**: SKU tier cannot be changed after creation; must recreate
- **Scaling**: Firewall automatically scales based on throughput
- **Cost**: Costs depend on tier (Standard or Premium) and data processing
- **Availability**: Built-in redundancy; no additional configuration needed
- **Management**: Can be managed individually or via Firewall Manager
- **Compliance**: Supports PCI DSS, HIPAA, and other compliance requirements

## Module Maintenance

### Version History

- **v1.0.0** - Initial release
  - Azure Firewall creation with Standard and Premium tiers
  - IP configuration with public IP
  - Diagnostic logging to Log Analytics
  - Tagging support

### Contributing

When contributing to this module:
1. Run `terraform fmt` to format code
2. Run `terraform validate` to check syntax
3. Test with both Standard and Premium tiers
4. Verify diagnostic settings work correctly
5. Test route table associations
6. Verify firewall rule application
7. Run security scans with Terrascan or tfsec
8. Update documentation for any new variables or outputs

## References

- [Azure Firewall Documentation](https://learn.microsoft.com/en-us/azure/firewall/overview)
- [Azure Firewall SKU Comparison](https://learn.microsoft.com/en-us/azure/firewall/choose-firewall-sku)
- [Firewall Application Rules](https://learn.microsoft.com/en-us/azure/firewall/rule-processing)
- [Firewall Network Rules](https://learn.microsoft.com/en-us/azure/firewall/firewall-workbook)
- [Azure Firewall Manager](https://learn.microsoft.com/en-us/azure/firewall-manager/overview)
- [Firewall Rule Processing Logic](https://learn.microsoft.com/en-us/azure/firewall/rule-processing)
- [Terraform AzureRM Firewall](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall)
- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure Firewall Best Practices](https://learn.microsoft.com/en-us/azure/firewall/deployment-planning)
- [Hub and Spoke Architecture](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
