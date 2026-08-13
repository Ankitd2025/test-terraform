# Azure Route Table Module

This Terraform module creates an Azure Route Table (User-Defined Routes) for custom routing configurations, enabling advanced network traffic management and routing to specific next hops including firewalls, VPN gateways, and virtual appliances.

## Description

Azure Route Tables enable custom routing configurations in virtual networks by allowing you to define routes that override Azure's default system routes. This module simplifies the creation of route tables with support for multiple route types, next hop destinations, and comprehensive tagging for network segmentation and policy enforcement.

## Features

- ✅ Custom routing configuration
- ✅ Multiple route types (Internet, VirtualAppliance, VirtualNetworkGateway, VnetLocal, None)
- ✅ Dynamic route definitions
- ✅ Firewall routing (User-Defined Routes)
- ✅ VPN gateway routing
- ✅ Virtual appliance routing
- ✅ System route override capability
- ✅ Forced tunneling support
- ✅ Regional deployment
- ✅ Subnet association
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
| `azurerm_route_table` | The Azure Route Table resource |

## Prerequisites

Before using this module, you should have:

1. **Resource Group** where the route table will be created
2. **Azure Subscription** with appropriate permissions
3. **Region** where the route table will be deployed
4. **Next Hop Resources** (firewall, VPN gateway, or appliance) if required

## Usage

### Basic Route Table with Internet Route

```hcl
module "route_table" {
  source = "./modules/route-table"
  
  name                = "rt-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  
  route = [
    {
      name                = "allow-internet"
      address_prefix      = "0.0.0.0/0"
      next_hop_type       = "Internet"
      next_hop_ip_address = null
    }
  ]
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Associate with subnet
resource "azurerm_subnet_route_table_association" "example" {
  subnet_id      = azurerm_subnet.example.id
  route_table_id = module.route_table.route_table_id
}
```

### Route Table for Firewall (Force Tunneling)

```hcl
module "firewall_route_table" {
  source = "./modules/route-table"
  
  name                = "rt-firewall-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  
  route = [
    {
      name                = "default-to-firewall"
      address_prefix      = "0.0.0.0/0"
      next_hop_type       = "VirtualAppliance"
      next_hop_ip_address = "10.0.1.4"  # Firewall private IP
    },
    {
      name                = "local-vnet"
      address_prefix      = "10.0.0.0/16"
      next_hop_type       = "VnetLocal"
      next_hop_ip_address = null
    }
  ]
  
  tags = {
    Environment = "Production"
    Purpose     = "Firewall-Routing"
  }
}

# Associate with spoke subnet
resource "azurerm_subnet_route_table_association" "spoke" {
  subnet_id      = azurerm_subnet.spoke_workload.id
  route_table_id = module.firewall_route_table.route_table_id
}
```

### Route Table with Multiple Routes

```hcl
module "route_table_multi" {
  source = "./modules/route-table"
  
  name                = "rt-complex-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  
  route = [
    {
      name                = "default-internet"
      address_prefix      = "0.0.0.0/0"
      next_hop_type       = "Internet"
      next_hop_ip_address = null
    },
    {
      name                = "to-onprem"
      address_prefix      = "192.168.0.0/16"
      next_hop_type       = "VirtualNetworkGateway"
      next_hop_ip_address = null
    },
    {
      name                = "to-security-appliance"
      address_prefix      = "172.16.0.0/12"
      next_hop_type       = "VirtualAppliance"
      next_hop_ip_address = "10.0.2.20"
    },
    {
      name                = "local-network"
      address_prefix      = "10.0.0.0/16"
      next_hop_type       = "VnetLocal"
      next_hop_ip_address = null
    },
    {
      name                = "block-internal"
      address_prefix      = "10.1.0.0/16"
      next_hop_type       = "None"
      next_hop_ip_address = null
    }
  ]
  
  tags = {
    Environment = "Production"
    Tier        = "Enterprise"
  }
}
```

### Hub and Spoke Routing Architecture

```hcl
locals {
  common_tags = {
    Environment = "Production"
    Project     = "IncumbentFI"
    ManagedBy   = "Terraform"
  }
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

# Hub Firewall (deployed in AzureFirewallSubnet)
module "hub_firewall" {
  source = "./modules/firewall"
  
  name                = "fw-hub-prod-eastus-001"
  resource_group_name = module.hub_rg.resource_group_name
  location            = "eastus"
  
  # ... firewall configuration ...
}

# Spoke Virtual Network
module "spoke_vnet" {
  source = "./modules/virtual-network"
  
  name                = "vnet-spoke-prod-eastus-001"
  resource_group_name = module.spoke_rg.resource_group_name
  location            = "eastus"
  address_space       = ["10.1.0.0/16"]
  
  tags = local.common_tags
}

# Spoke Route Table - Route all traffic through hub firewall
module "spoke_route_table" {
  source = "./modules/route-table"
  
  name                = "rt-spoke-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.spoke_rg.resource_group_name
  
  route = [
    {
      name                = "default-to-firewall"
      address_prefix      = "0.0.0.0/0"
      next_hop_type       = "VirtualAppliance"
      next_hop_ip_address = "10.0.1.4"  # Hub firewall private IP
    },
    {
      name                = "local-spoke"
      address_prefix      = "10.1.0.0/16"
      next_hop_type       = "VnetLocal"
      next_hop_ip_address = null
    }
  ]
  
  tags = merge(local.common_tags, {
    Role = "Spoke"
  })
}

# Associate route table with spoke workload subnet
resource "azurerm_subnet_route_table_association" "spoke_workload" {
  subnet_id      = azurerm_subnet.spoke_workload.id
  route_table_id = module.spoke_route_table.route_table_id
}

# VNet Peering (hub to spoke)
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "peer-hub-to-spoke"
  resource_group_name       = module.hub_rg.resource_group_name
  virtual_network_name      = module.hub_vnet.virtual_network_name
  remote_virtual_network_id = module.spoke_vnet.virtual_network_id
  
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "peer-spoke-to-hub"
  resource_group_name       = module.spoke_rg.resource_group_name
  virtual_network_name      = module.spoke_vnet.virtual_network_name
  remote_virtual_network_id = module.hub_vnet.virtual_network_id
  
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = true
}

output "spoke_route_table_id" {
  value = module.spoke_route_table.route_table_id
}
```

### Forced Tunneling Configuration

```hcl
module "forced_tunnel_rt" {
  source = "./modules/route-table"
  
  name                = "rt-forced-tunnel-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  
  route = [
    {
      name                = "force-internet-to-firewall"
      address_prefix      = "0.0.0.0/0"
      next_hop_type       = "VirtualAppliance"
      next_hop_ip_address = "10.0.1.4"  # Firewall
    },
    {
      name                = "allow-local"
      address_prefix      = "10.0.0.0/16"
      next_hop_type       = "VnetLocal"
      next_hop_ip_address = null
    },
    {
      name                = "allow-hub"
      address_prefix      = "10.0.0.0/16"
      next_hop_type       = "VirtualNetworkGateway"
      next_hop_ip_address = null
    }
  ]
  
  tags = {
    Environment = "Production"
    Purpose     = "Forced-Tunneling"
  }
}

# Apply to workload subnet
resource "azurerm_subnet_route_table_association" "workload" {
  subnet_id      = azurerm_subnet.workload.id
  route_table_id = module.forced_tunnel_rt.route_table_id
}
```

### VPN Gateway Routing

```hcl
module "vpn_route_table" {
  source = "./modules/route-table"
  
  name                = "rt-vpn-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  
  route = [
    {
      name                = "default-internet"
      address_prefix      = "0.0.0.0/0"
      next_hop_type       = "Internet"
      next_hop_ip_address = null
    },
    {
      name                = "onprem-via-vpn"
      address_prefix      = "192.168.0.0/16"
      next_hop_type       = "VirtualNetworkGateway"
      next_hop_ip_address = null
    },
    {
      name                = "local-network"
      address_prefix      = "10.0.0.0/16"
      next_hop_type       = "VnetLocal"
      next_hop_ip_address = null
    }
  ]
  
  tags = {
    Environment = "Production"
    Purpose     = "VPN-Routing"
  }
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | The name of the Route Table | `string` | Yes | n/a |
| location | The Azure region for the route table | `string` | Yes | n/a |
| resource_group_name | The name of the resource group | `string` | Yes | n/a |
| route | List of route objects with name, address_prefix, next_hop_type, and optional next_hop_ip_address | `list(object)` | Yes | n/a |
| tags | Tags to assign to the route table | `map(string)` | No | `{}` |

### Route Object Schema

```hcl
route = [
  {
    name                = string           # Route name
    address_prefix      = string           # CIDR notation (e.g., "0.0.0.0/0")
    next_hop_type       = string           # See Next Hop Types
    next_hop_ip_address = optional(string) # IP address (required for VirtualAppliance)
  }
]
```

## Outputs

| Name | Description |
|------|-------------|
| route_table_id | The ID of the Route Table |
| route_table_name | The name of the Route Table |

## Next Hop Types

### Internet

Routes traffic to the public internet through Azure's default routing.

```hcl
{
  name                = "route-to-internet"
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
  next_hop_ip_address = null
}
```

**Use Cases:**
- Default internet access
- Outbound to public services
- Direct internet connectivity

### VirtualNetworkGateway

Routes traffic through a VPN Gateway or ExpressRoute Gateway.

```hcl
{
  name                = "route-to-onprem"
  address_prefix      = "192.168.0.0/16"
  next_hop_type       = "VirtualNetworkGateway"
  next_hop_ip_address = null
}
```

**Use Cases:**
- On-premises connectivity via VPN
- ExpressRoute circuits
- Hybrid networking

**Requirements:**
- VPN Gateway or ExpressRoute Gateway must exist in VNet
- Gateway must be associated with the VNet

### VirtualAppliance

Routes traffic through a custom network appliance (firewall, NVA, etc.).

```hcl
{
  name                = "route-to-firewall"
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualAppliance"
  next_hop_ip_address = "10.0.1.4"  # Required
}
```

**Use Cases:**
- Firewall routing
- Network virtual appliance (NVA)
- Security inspection
- Packet filtering

**Requirements:**
- Next hop IP address must be specified
- IP must be in a reachable subnet
- Appliance must be configured for IP forwarding
- Appliance must route traffic appropriately

### VnetLocal

Routes traffic within the same virtual network (system route).

```hcl
{
  name                = "local-vnet"
  address_prefix      = "10.0.0.0/16"
  next_hop_type       = "VnetLocal"
  next_hop_ip_address = null
}
```

**Use Cases:**
- Local network traffic
- Overriding default routes
- Forcing specific subnets to VnetLocal

**Note:** This is typically handled by system routes automatically.

### None

Drops traffic matching the route (black hole route).

```hcl
{
  name                = "block-traffic"
  address_prefix      = "10.1.0.0/16"
  next_hop_type       = "None"
  next_hop_ip_address = null
}
```

**Use Cases:**
- Block specific destinations
- Deny by default patterns
- Security policy enforcement

## Route Priority and Processing

Routes are evaluated in priority order:

1. **Most Specific Match** - Routes with longest prefix match (highest precedence)
2. **Priority by Next Hop Type**:
   - System routes (VnetLocal) - Highest
   - User routes (all types) - Based on specificity
   - Default route (0.0.0.0/0) - Lowest

### Example Priority Processing

```
Route 1: 10.0.0.0/16 → VnetLocal (System) - Highest priority
Route 2: 10.0.0.0/24 → VirtualAppliance - Higher priority than /16
Route 3: 0.0.0.0/0 → Internet - Default route (Lowest)

For destination 10.0.1.5:
- Matches 10.0.0.0/16 (Route 1) ✓
- Matches 0.0.0.0/0 (Route 3) ✓
- Selected: Route 1 (most specific)
```

## Subnet Association

### Associate Route Table with Subnet

```hcl
resource "azurerm_subnet_route_table_association" "example" {
  subnet_id      = azurerm_subnet.example.id
  route_table_id = module.route_table.route_table_id
}
```

### Multiple Subnet Associations

```hcl
# Associate with multiple subnets
resource "azurerm_subnet_route_table_association" "workload_1" {
  subnet_id      = azurerm_subnet.workload_1.id
  route_table_id = module.route_table.route_table_id
}

resource "azurerm_subnet_route_table_association" "workload_2" {
  subnet_id      = azurerm_subnet.workload_2.id
  route_table_id = module.route_table.route_table_id
}

resource "azurerm_subnet_route_table_association" "workload_3" {
  subnet_id      = azurerm_subnet.workload_3.id
  route_table_id = module.route_table.route_table_id
}
```

## Route Table Propagation

### BGP Route Propagation

Routes can be learned dynamically via BGP when using VPN Gateway:

```hcl
resource "azurerm_virtual_network_gateway_bgp_settings" "bgp" {
  resource_group_name        = azurerm_resource_group.example.name
  virtual_network_gateway_id = azurerm_virtual_network_gateway.example.id
  
  asn = 65000
}
```

**With BGP Propagation:**
- Routes from on-premises automatically propagated
- Dynamic route updates
- No manual route table updates needed

**Without BGP Propagation:**
- Manual route updates required
- Static routing configuration
- Manual synchronization needed

## Hub and Spoke Routing Patterns

### Pattern 1: All Spoke Traffic Through Hub Firewall

```
Spoke VM → Route Table (0.0.0.0/0 → Firewall IP) → Hub Firewall → Internet
```

**Route Table Configuration:**
```hcl
route = [
  {
    name                = "default-to-firewall"
    address_prefix      = "0.0.0.0/0"
    next_hop_type       = "VirtualAppliance"
    next_hop_ip_address = "10.0.1.4"  # Hub Firewall
  },
  {
    name                = "local-spoke"
    address_prefix      = "10.1.0.0/16"
    next_hop_type       = "VnetLocal"
    next_hop_ip_address = null
  }
]
```

### Pattern 2: Selective Routing

```
Spoke VM → Route Table (Azure services → Internet | On-premises → VPN)
```

**Route Table Configuration:**
```hcl
route = [
  {
    name                = "azure-services"
    address_prefix      = "0.0.0.0/0"
    next_hop_type       = "Internet"
    next_hop_ip_address = null
  },
  {
    name                = "onprem"
    address_prefix      = "192.168.0.0/16"
    next_hop_type       = "VirtualNetworkGateway"
    next_hop_ip_address = null
  },
  {
    name                = "local-spoke"
    address_prefix      = "10.1.0.0/16"
    next_hop_type       = "VnetLocal"
    next_hop_ip_address = null
  }
]
```

## Security Best Practices

1. **Explicit Routes** - Define all required routes explicitly
2. **Least Privilege** - Only allow necessary traffic routes
3. **Firewall Inspection** - Route through firewalls for inspection
4. **Block Routes** - Use "None" next hop to block unwanted traffic
5. **Network Segmentation** - Different route tables per security tier
6. **Monitoring** - Enable Network Watcher to monitor traffic flow
7. **Documentation** - Document routing policies and changes
8. **Testing** - Test routes before production deployment
9. **Segregation** - Separate route tables for different workload types
10. **Validation** - Regularly audit route table configurations

## Naming Conventions

Follow [Azure naming conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming):

- **Length**: 1-80 characters
- **Valid characters**: Alphanumerics, hyphens, underscores
- **Start with**: Alphanumeric
- **End with**: Alphanumeric
- **Recommended pattern**: `rt-<application>-<environment>-<region>-<instance>`

### Examples

- `rt-prod-eastus-001` - Production route table in East US
- `rt-firewall-prod-eastus-001` - Firewall routing in production
- `rt-vpn-prod-eastus-001` - VPN routing in production
- `rt-spoke-prod-eastus-001` - Spoke routing in production
- `rt-forced-tunnel-prod-eastus-001` - Forced tunneling configuration

### Route Naming

- `route-to-internet` - Routes to internet
- `route-to-firewall` - Routes through firewall
- `route-to-onprem` - Routes to on-premises via VPN/ExpressRoute
- `local-vnet` - Local VNet traffic
- `default-to-firewall` - Default route through firewall

## Troubleshooting

### Common Issues

**Issue**: Traffic not following expected route
- **Solution**:
  1. Verify route table is associated with correct subnet
  2. Check route priority (most specific match wins)
  3. Verify next hop IP is reachable
  4. Check network appliance accepts traffic
  5. Review Network Watcher NSG flow logs

**Issue**: Next hop IP (virtual appliance) not reachable
- **Solution**:
  1. Verify VM/appliance IP forwarding is enabled
  2. Check appliance is running and configured
  3. Verify NSG allows traffic to appliance
  4. Ensure appliance can route return traffic
  5. Check routing on the appliance itself

**Issue**: Route table not applied to subnet
- **Solution**:
  1. Verify route table association exists
  2. Check subnet ID is correct
  3. Ensure route table is in same region
  4. Look for terraform drift or manual changes
  5. Verify IAM permissions for association

**Issue**: BGP routes not propagating
- **Solution**:
  1. Verify BGP is enabled on VPN Gateway
  2. Check local network gateway configuration
  3. Ensure VPN connection is established
  4. Verify ASN is within private range (64512-65534)
  5. Check on-premises device BGP configuration

**Issue**: Asymmetric routing
- **Solution**:
  1. Verify return routes exist on all hops
  2. Ensure firewall/appliance can route return traffic
  3. Check NSG rules allow return traffic
  4. Verify route priority on return path
  5. Test with traceroute or ping

### Validation Commands

```powershell
# Show route table details
az network route-table show --name rt-prod-eastus-001 \
  --resource-group rg-prod-001

# List routes in route table
az network route-table route list --name rt-prod-eastus-001 \
  --resource-group rg-prod-001 --output table

# Show route table associations
az network route-table show --name rt-prod-eastus-001 \
  --resource-group rg-prod-001 --query "subnets"

# Test network routing (from VM)
Test-NetConnection -ComputerName 10.0.1.4 -TraceRoute

# View effective routes on NIC
az network nic show-effective-route-table --name nic-vm-001 \
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
terrascan scan -d ./modules/route-table -i terraform

# Lint check
tflint --init
tflint
```

## Notes

- **System Routes** - Azure automatically creates system routes (cannot be deleted)
- **Route Priority** - Most specific (longest prefix match) takes precedence
- **CIDR Notation** - Must be valid CIDR format (e.g., 10.0.0.0/24)
- **No Bidirectional** - Routes only define outbound direction; return routes must be configured separately
- **Propagation** - BGP routes can override user-defined routes with more specific matches
- **Regional** - Route tables are regional resources
- **Multiple Route Tables** - One per subnet or shared across multiple subnets
- **No Cost** - Route tables incur no direct charge (only through associated resources)

## Module Maintenance

### Version History

- **v1.0.0** - Initial release
  - Route table creation
  - Multiple route definitions
  - Support for all next hop types
  - Dynamic route configuration
  - Tagging support

### Contributing

When contributing to this module:
1. Run `terraform fmt` to format code
2. Run `terraform validate` to check syntax
3. Test with different next hop types
4. Test subnet associations
5. Verify route priority processing
6. Test with Network Watcher
7. Run security scans with Terrascan or tfsec
8. Update documentation for any new variables or outputs

## References

- [Azure Route Tables Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/manage-route-table)
- [User-Defined Routes (UDR)](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview)
- [Next Hop Types](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview#next-hophop-type)
- [BGP Route Propagation](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-bgp-overview)
- [Forced Tunneling](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-forced-tunneling-rm)
- [Hub and Spoke Network](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [Network Watcher](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-overview)
- [Terraform AzureRM Route Table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table)
- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
