# Azure VPN Gateway Module

This Terraform module creates an Azure VPN Gateway for secure site-to-site connectivity, point-to-site access, or ExpressRoute circuits with support for active-active configurations and BGP routing.

## Description

Azure VPN Gateway provides a highly scalable, resilient gateway for encrypted connections to on-premises networks, remote offices, and branch locations. This module simplifies the creation of VPN gateways with support for multiple SKUs, VPN types, active-active failover, and dynamic routing via BGP.

## Features

- ✅ Site-to-site (S2S) VPN connections
- ✅ Point-to-site (P2S) VPN access
- ✅ ExpressRoute circuit support
- ✅ Active-active failover (RouteBased)
- ✅ BGP dynamic routing
- ✅ Multiple SKU options (Basic through VpnGw5)
- ✅ Route-based and policy-based VPN types
- ✅ Public IP association
- ✅ Static and dynamic private IP allocation
- ✅ Regional and multi-region deployment
- ✅ Comprehensive tagging support

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

| Resource Type | Description |
|--------------|-------------|
| `azurerm_virtual_network_gateway` | The Azure VPN Gateway resource |

## Prerequisites

Before using this module, you should have:

1. **Virtual Network** with a dedicated GatewaySubnet
2. **Public IP Address** (Standard SKU recommended)
3. **Subnet** specifically named "GatewaySubnet" (/27 minimum recommended)
4. **Azure Subscription** with appropriate permissions
5. **Region** where the gateway will be deployed

## Usage

### Basic Site-to-Site VPN Gateway (RouteBased)

```hcl
module "vpn_gateway" {
  source = "./modules/vpn-gateway"
  
  name                          = "vpngw-prod-eastus-001"
  location                      = "eastus"
  resource_group_name           = module.resource_group.resource_group_name
  type                          = "Vpn"
  vpn_type                      = "RouteBased"
  sku                           = "VpnGw1"
  active_active                 = false
  bgp_enabled                   = false
  
  ip_configuration_name         = "vnetGatewayConfig"
  public_ip_address_id          = azurerm_public_ip.vpn_pip.id
  subnet_id                     = azurerm_subnet.gateway_subnet.id
  private_ip_address_allocation = "Dynamic"
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### VPN Gateway with BGP Dynamic Routing

```hcl
module "vpn_gateway_bgp" {
  source = "./modules/vpn-gateway"
  
  name                          = "vpngw-prod-eastus-001"
  location                      = "eastus"
  resource_group_name           = module.resource_group.resource_group_name
  type                          = "Vpn"
  vpn_type                      = "RouteBased"
  sku                           = "VpnGw2"
  active_active                 = false
  bgp_enabled                   = true  # Enable dynamic routing
  
  ip_configuration_name         = "vnetGatewayConfig"
  public_ip_address_id          = azurerm_public_ip.vpn_pip.id
  subnet_id                     = azurerm_subnet.gateway_subnet.id
  private_ip_address_allocation = "Dynamic"
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Configure BGP settings
resource "azurerm_virtual_network_gateway_bgp_settings" "bgp" {
  resource_group_name       = module.resource_group.resource_group_name
  virtual_network_gateway_id = module.vpn_gateway_bgp.vpn_gateway_id
  asn                       = 65000
}
```

### Active-Active VPN Gateway for High Availability

```hcl
# Create two public IPs for active-active setup
resource "azurerm_public_ip" "vpn_pip_primary" {
  name                = "pip-vpngw-primary-eastus-001"
  resource_group_name = module.resource_group.resource_group_name
  location            = "eastus"
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "vpn_pip_secondary" {
  name                = "pip-vpngw-secondary-eastus-001"
  resource_group_name = module.resource_group.resource_group_name
  location            = "eastus"
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Primary VPN Gateway
module "vpn_gateway_primary" {
  source = "./modules/vpn-gateway"
  
  name                          = "vpngw-prod-eastus-001"
  location                      = "eastus"
  resource_group_name           = module.resource_group.resource_group_name
  type                          = "Vpn"
  vpn_type                      = "RouteBased"
  sku                           = "VpnGw2"
  active_active                 = true  # Enable active-active
  bgp_enabled                   = true
  
  ip_configuration_name         = "vnetGatewayConfig"
  public_ip_address_id          = azurerm_public_ip.vpn_pip_primary.id
  subnet_id                     = azurerm_subnet.gateway_subnet.id
  private_ip_address_allocation = "Dynamic"
  
  tags = {
    Environment = "Production"
    Role        = "Primary"
  }
}

# Secondary IP configuration for active-active
resource "azurerm_virtual_network_gateway_bgp_settings" "active_active" {
  resource_group_name        = module.resource_group.resource_group_name
  virtual_network_gateway_id = module.vpn_gateway_primary.vpn_gateway_id
  asn                        = 65000
}
```

### ExpressRoute Gateway

```hcl
module "expressroute_gateway" {
  source = "./modules/vpn-gateway"
  
  name                          = "ergw-prod-eastus-001"
  location                      = "eastus"
  resource_group_name           = module.resource_group.resource_group_name
  type                          = "ExpressRoute"  # ExpressRoute type
  vpn_type                      = "RouteBased"
  sku                           = "Standard"      # ExpressRoute specific SKU
  active_active                 = false
  bgp_enabled                   = true
  
  ip_configuration_name         = "vnetGatewayConfig"
  public_ip_address_id          = azurerm_public_ip.er_pip.id
  subnet_id                     = azurerm_subnet.gateway_subnet.id
  private_ip_address_allocation = "Dynamic"
  
  tags = {
    Environment = "Production"
    Type        = "ExpressRoute"
  }
}
```

### Complete Hub and Spoke with VPN Gateway

```hcl
locals {
  common_tags = {
    Environment = "Production"
    Project     = "IncumbentFI"
    ManagedBy   = "Terraform"
  }
}

# Hub Resource Group
module "hub_rg" {
  source = "./modules/resource-group"
  
  name     = "rg-hub-prod-eastus-001"
  location = "eastus"
  tags     = local.common_tags
}

# Hub Virtual Network
module "hub_vnet" {
  source = "./modules/virtual-network"
  
  name                = "vnet-hub-prod-eastus-001"
  resource_group_name = module.hub_rg.resource_group_name
  location            = "eastus"
  address_space       = ["10.0.0.0/16"]
  
  tags = local.common_tags
}

# Gateway Subnet (required for VPN Gateway)
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = module.hub_rg.resource_group_name
  virtual_network_name = module.hub_vnet.virtual_network_name
  address_prefixes     = ["10.0.1.0/27"]
}

# Public IP for VPN Gateway
resource "azurerm_public_ip" "vpn_pip" {
  name                = "pip-vpngw-prod-eastus-001"
  resource_group_name = module.hub_rg.resource_group_name
  location            = "eastus"
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = local.common_tags
}

# VPN Gateway
module "vpn_gateway" {
  source = "./modules/vpn-gateway"
  
  name                          = "vpngw-hub-prod-eastus-001"
  location                      = "eastus"
  resource_group_name           = module.hub_rg.resource_group_name
  type                          = "Vpn"
  vpn_type                      = "RouteBased"
  sku                           = "VpnGw2"
  active_active                 = false
  bgp_enabled                   = true
  
  ip_configuration_name         = "vnetGatewayConfig"
  public_ip_address_id          = azurerm_public_ip.vpn_pip.id
  subnet_id                     = azurerm_subnet.gateway.id
  private_ip_address_allocation = "Dynamic"
  
  tags = local.common_tags
}

# Local Network Gateway (on-premises network)
resource "azurerm_local_network_gateway" "on_premises" {
  name                = "lng-onprem-eastus-001"
  resource_group_name = module.hub_rg.resource_group_name
  location            = "eastus"
  gateway_address     = "203.0.113.1"  # On-premises VPN endpoint
  address_space       = ["192.168.0.0/16"]  # On-premises address space
  
  tags = local.common_tags
}

# VPN Connection
resource "azurerm_vpn_connection" "site_to_site" {
  name                = "conn-hub-to-onprem-001"
  resource_group_name = module.hub_rg.resource_group_name
  location            = "eastus"
  
  type                       = "IPsec"
  virtual_network_gateway_id = module.vpn_gateway.vpn_gateway_id
  local_network_gateway_id   = azurerm_local_network_gateway.on_premises.id
  
  shared_key = "MySecureSharedKey123!"
  
  tags = local.common_tags
}

output "vpn_gateway_id" {
  value       = module.vpn_gateway.vpn_gateway_id
  description = "ID of the VPN Gateway"
}

output "vpn_gateway_public_ip" {
  value       = azurerm_public_ip.vpn_pip.ip_address
  description = "Public IP address of the VPN Gateway"
}
```

### Policy-Based VPN Gateway

```hcl
# Policy-based gateway (legacy, deprecated)
module "vpn_gateway_policy" {
  source = "./modules/vpn-gateway"
  
  name                          = "vpngw-policy-prod-eastus-001"
  location                      = "eastus"
  resource_group_name           = module.resource_group.resource_group_name
  type                          = "Vpn"
  vpn_type                      = "PolicyBased"  # Older approach
  sku                           = "Basic"
  active_active                 = false
  bgp_enabled                   = false
  
  ip_configuration_name         = "vnetGatewayConfig"
  public_ip_address_id          = azurerm_public_ip.vpn_pip.id
  subnet_id                     = azurerm_subnet.gateway_subnet.id
  private_ip_address_allocation = "Dynamic"
  
  tags = {
    Environment = "Production"
    Type        = "PolicyBased"
  }
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | The name of the VPN Gateway | `string` | Yes | n/a |
| location | The Azure region for the gateway | `string` | Yes | n/a |
| resource_group_name | The name of the resource group | `string` | Yes | n/a |
| type | Gateway type: "Vpn" or "ExpressRoute" | `string` | Yes | n/a |
| vpn_type | VPN type: "RouteBased" or "PolicyBased" | `string` | Yes | n/a |
| sku | Gateway SKU (Basic, VpnGw1-5 for VPN; Standard, HighPerformance for ExpressRoute) | `string` | Yes | n/a |
| active_active | Enable active-active failover (RouteBased only) | `bool` | No | `false` |
| bgp_enabled | Enable BGP dynamic routing | `bool` | No | `false` |
| ip_configuration_name | Name of the IP configuration | `string` | Yes | n/a |
| public_ip_address_id | ID of the public IP address | `string` | Yes | n/a |
| private_ip_address_allocation | Private IP allocation: "Static" or "Dynamic" | `string` | Yes | n/a |
| subnet_id | ID of the GatewaySubnet | `string` | Yes | n/a |
| tags | Tags to assign to the gateway | `map(string)` | No | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| vpn_gateway_id | The ID of the VPN Gateway |
| vpn_gateway_name | The name of the VPN Gateway |
| vpn_gateway_resource_group_name | The resource group name |
| vpn_gateway_location | The location of the gateway |

## Gateway Types

### VPN Gateway

**Type Configuration:**
```hcl
type = "Vpn"
```

**Capabilities:**
- ✅ Site-to-site (S2S) connections
- ✅ Point-to-site (P2S) access
- ✅ VPN to VPN connections
- ✅ ExpressRoute coexistence
- ✅ Active-active failover
- ✅ BGP dynamic routing
- ✅ Multiple SKU options

**Supported SKUs:**
- Basic (legacy, limited throughput)
- VpnGw1, VpnGw1AZ
- VpnGw2, VpnGw2AZ
- VpnGw3, VpnGw3AZ
- VpnGw4, VpnGw4AZ
- VpnGw5, VpnGw5AZ

### ExpressRoute Gateway

**Type Configuration:**
```hcl
type = "ExpressRoute"
```

**Capabilities:**
- ✅ ExpressRoute circuit connections
- ✅ Private connectivity to Azure
- ✅ Coexistence with VPN
- ❌ No VPN tunnels
- ❌ No active-active failover

**Supported SKUs:**
- Standard
- HighPerformance
- UltraPerformance

## VPN Types

### Route-Based VPN

**Type Configuration:**
```hcl
vpn_type = "RouteBased"
```

**Features:**
- ✅ Modern, recommended approach
- ✅ Supports active-active failover
- ✅ Better performance
- ✅ Dynamic routing protocols (BGP)
- ✅ Multiple tunnels
- ✅ IKEv2 support

**Use Case:** Production deployments, high availability requirements

### Policy-Based VPN

**Type Configuration:**
```hcl
vpn_type = "PolicyBased"
```

**Features:**
- ✅ Legacy approach (deprecated)
- ❌ No active-active support
- ❌ Limited functionality
- ❌ Static routing only
- ❌ Single tunnel per connection
- ✅ IKEv1 support

**Use Case:** Legacy on-premises systems (NOT recommended for new deployments)

## SKU Comparison

### VPN Gateway SKUs

| SKU | Throughput | S2S Tunnels | P2S Connections | BGP | Active-Active | ExpressRoute | Use Case |
|-----|-----------|------------|-----------------|-----|--------------|--------------|----------|
| Basic | 100 Mbps | 10 | 128 | ❌ | ❌ | ❌ | Dev/Test only |
| VpnGw1 | 650 Mbps | 30 | 128 | ✅ | ✅ | ✅ | Small deployments |
| VpnGw1AZ | 650 Mbps | 30 | 128 | ✅ | ✅ | ✅ | Zone-redundant small |
| VpnGw2 | 1 Gbps | 40 | 128 | ✅ | ✅ | ✅ | Medium deployments |
| VpnGw2AZ | 1 Gbps | 40 | 128 | ✅ | ✅ | ✅ | Zone-redundant medium |
| VpnGw3 | 1.25 Gbps | 200 | 128 | ✅ | ✅ | ✅ | Large deployments |
| VpnGw3AZ | 1.25 Gbps | 200 | 128 | ✅ | ✅ | ✅ | Zone-redundant large |
| VpnGw4 | 5 Gbps | 200 | 500 | ✅ | ✅ | ✅ | Enterprise scale |
| VpnGw4AZ | 5 Gbps | 200 | 500 | ✅ | ✅ | ✅ | Zone-redundant enterprise |
| VpnGw5 | 10 Gbps | 200 | 500 | ✅ | ✅ | ✅ | Maximum performance |
| VpnGw5AZ | 10 Gbps | 200 | 500 | ✅ | ✅ | ✅ | Zone-redundant maximum |

### ExpressRoute Gateway SKUs

| SKU | Circuits | ExpressRoute Local | Cost |
|-----|----------|------------------|------|
| Standard | 10 | ✅ | Standard |
| HighPerformance | 10 | ✅ | Higher cost |
| UltraPerformance | 10 | ✅ | Highest cost |

## BGP Configuration

### Enable BGP

```hcl
# Create VPN Gateway with BGP
module "vpn_gateway" {
  source = "./modules/vpn-gateway"
  
  # ... other configuration ...
  bgp_enabled = true
}

# Configure BGP settings
resource "azurerm_virtual_network_gateway_bgp_settings" "bgp" {
  resource_group_name        = module.resource_group.resource_group_name
  virtual_network_gateway_id = module.vpn_gateway.vpn_gateway_id
  
  asn = 65000  # Private ASN (64512-65534)
}
```

### BGP Features

- **Dynamic Routing** - Routes advertised via BGP ASN
- **High Availability** - Automatic failover via BGP convergence
- **Multi-Site Connectivity** - Multiple on-premises networks
- **Route Aggregation** - Summarize routes for efficiency
- **AS Path Prepending** - Control traffic flow

### BGP Limitations

- Requires RouteBased VPN type
- Not supported with PolicyBased VPN
- Minimum SKU: VpnGw1
- Private ASN range: 64512-65534
- Public ASN: Requires Microsoft approval

## Gateway Subnet Requirements

### Subnet Configuration

```hcl
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"  # MUST be named exactly this
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/27"]  # Minimum /27
}
```

### Subnet Rules

- **Name** must be exactly "GatewaySubnet"
- **Size** minimum /27 (32 IP addresses)
- **Recommended** /25 or larger for future expansion
- **No delegation** allowed
- **No NSG** on gateway subnet (Azure managed)
- **Single subnet** per virtual network

## Active-Active Configuration

### Requirements

- **VPN Type** - RouteBased only
- **Minimum SKU** - VpnGw1 or higher
- **Two Public IPs** - Primary and secondary
- **BGP Enabled** - Recommended for high availability

### Active-Active Setup

```hcl
# Primary and secondary public IPs
resource "azurerm_public_ip" "primary" {
  name                = "pip-primary-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "secondary" {
  name                = "pip-secondary-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Active-active gateway
module "vpn_gateway" {
  source = "./modules/vpn-gateway"
  
  # ... other configuration ...
  active_active                 = true
  public_ip_address_id          = azurerm_public_ip.primary.id
}

# Secondary IP configuration
resource "azurerm_virtual_network_gateway_bgp_settings" "active_active" {
  resource_group_name        = azurerm_resource_group.example.name
  virtual_network_gateway_id = module.vpn_gateway.vpn_gateway_id
  
  asn           = 65000
}
```

## Naming Conventions

Follow [Azure naming conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming):

- **Length**: 1-80 characters
- **Valid characters**: Alphanumerics, hyphens
- **Start with**: Alphanumeric
- **End with**: Alphanumeric
- **Recommended pattern**: `vpngw-<application>-<environment>-<region>-<instance>`

### Examples

- `vpngw-prod-eastus-001` - Production VPN gateway in East US
- `vpngw-hub-prod-eastus-001` - Hub VPN gateway in production
- `ergw-prod-eastus-001` - ExpressRoute gateway in production
- `vpngw-drtesting-eastus-001` - Disaster recovery test gateway

## Security Best Practices

1. **Use Route-Based VPN** - RouteBased is modern and recommended
2. **Enable BGP** - For dynamic routing and high availability
3. **Active-Active** - Deploy with failover for production
4. **Strong Shared Keys** - Use complex pre-shared keys (32+ characters)
5. **Encryption Policies** - Use IPsec encryption (AES256)
6. **Zone Redundancy** - Use AZ SKUs for fault tolerance
7. **Public IP** - Use Standard SKU for guaranteed quality
8. **Network Security** - Secure gateway subnet with NSGs
9. **Monitoring** - Enable diagnostics and monitoring
10. **Regular Updates** - Keep on-premises VPN devices updated

## Site-to-Site Connection

### Create Local Network Gateway

```hcl
resource "azurerm_local_network_gateway" "on_premises" {
  name                = "lng-onprem-eastus-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  gateway_address     = "203.0.113.1"  # Public IP of on-premises VPN device
  address_space       = ["192.168.0.0/16"]  # On-premises networks
}
```

### Create VPN Connection

```hcl
resource "azurerm_vpn_connection" "site_to_site" {
  name                = "conn-hub-to-onprem-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  
  type                       = "IPsec"
  virtual_network_gateway_id = module.vpn_gateway.vpn_gateway_id
  local_network_gateway_id   = azurerm_local_network_gateway.on_premises.id
  
  shared_key = "MyComplexSharedKey1234567890123456789!"
}
```

## Point-to-Site Configuration

### Create P2S Configuration

```hcl
resource "azurerm_vpn_server_configuration" "p2s" {
  name                = "vpnconfig-p2s-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  
  authentication_methods {
    method = "EAP"
    eap_settings {
      eap_methods = ["PEAP"]
      peap_settings {
        peap_authentications = ["EAPCHAP"]
      }
    }
  }
}
```

## Troubleshooting

### Common Issues

**Issue**: Gateway subnet not found
- **Solution**:
  1. Verify subnet name is exactly "GatewaySubnet"
  2. Check subnet size is at least /27
  3. Ensure subnet exists in the virtual network

**Issue**: Public IP association fails
- **Solution**:
  1. Verify public IP exists and is in same region
  2. Check public IP is Standard SKU
  3. Ensure public IP allocation is Static

**Issue**: VPN connection drops frequently
- **Solution**:
  1. Check shared key is correct on both ends
  2. Verify IPsec encryption policy compatibility
  3. Check network latency and packet loss
  4. Enable DPD (Dead Peer Detection)

**Issue**: BGP routes not advertising
- **Solution**:
  1. Verify BGP is enabled on gateway
  2. Check ASN is valid private range (64512-65534)
  3. Ensure local network gateway has correct networks
  4. Verify BGP settings are configured

**Issue**: Active-active failover not working
- **Solution**:
  1. Verify SKU supports active-active (VpnGw1+)
  2. Check both public IPs are configured
  3. Ensure VPN type is RouteBased
  4. Verify BGP is enabled

### Validation Commands

```powershell
# Show VPN Gateway details
az network vnet-gateway show --name vpngw-prod-eastus-001 \
  --resource-group rg-prod-001

# List VPN connections
az network vpn-connection list \
  --resource-group rg-prod-001 --output table

# Check gateway status
az network vnet-gateway show --name vpngw-prod-eastus-001 \
  --resource-group rg-prod-001 --query "provisioningState"

# View BGP settings
az network vnet-gateway bgp-settings show \
  --vnet-gateway-name vpngw-prod-eastus-001 \
  --resource-group rg-prod-001

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
terrascan scan -d ./modules/vpn-gateway -i terraform

# Lint check
tflint --init
tflint
```

## Notes

- **Gateway Provisioning** - Takes 15-45 minutes to complete
- **SKU Change** - Requires gateway downtime (recreate)
- **Cost Implications** - Different SKUs have different pricing
- **Zone Redundancy** - AZ SKUs provide fault tolerance
- **Connection Limits** - S2S and P2S tunnels have limits per SKU
- **Routing** - BGP for dynamic or static routes for policy-based
- **Encryption** - Uses IPsec/IKEv2 for VPN security

## Module Maintenance

### Version History

- **v1.0.0** - Initial release
  - VPN and ExpressRoute gateway creation
  - Support for all SKU options
  - RouteBased and PolicyBased VPN types
  - Active-active configuration
  - BGP support

### Contributing

When contributing to this module:
1. Run `terraform fmt` to format code
2. Run `terraform validate` to check syntax
3. Test with different gateway types (VPN/ExpressRoute)
4. Test with different VPN types (RouteBased/PolicyBased)
5. Test active-active configuration
6. Verify BGP configuration
7. Run security scans with Terrascan or tfsec
8. Update documentation for any new variables or outputs

## References

- [Azure VPN Gateway Documentation](https://learn.microsoft.com/en-us/azure/vpn-gateway/)
- [VPN Gateway Configuration Overview](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpngateways)
- [Active-Active VPN Gateways](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-activeactive-rm-powershell)
- [BGP Configuration](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-bgp-overview)
- [Site-to-Site VPN Connections](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-site-to-site-resource-manager-portal)
- [Point-to-Site Connections](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-point-to-site-routing)
- [ExpressRoute Gateways](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-about-virtual-network-gateways)
- [Terraform AzureRM VPN Gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway)
- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
