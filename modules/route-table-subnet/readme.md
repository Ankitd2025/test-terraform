# Azure Route Table Subnet Association Module

This Terraform module creates an association between an Azure Route Table and a Subnet, enabling the route table's custom routing rules to be applied to all resources within that subnet.

## Description

Azure Subnet Route Table Association links a Route Table to a Subnet, effectively applying all custom routes defined in the route table to traffic originating from or destined to the subnet. This module provides a clean abstraction for subnet-to-route-table relationships, allowing flexible routing policy management and enforcement across network segments.

## Features

- ✅ Route table association with subnet
- ✅ Modular relationship management
- ✅ Clean separation of concerns
- ✅ Reusable association logic
- ✅ Support for multiple associations
- ✅ Terraform state management
- ✅ Easy disassociation capability
- ✅ Idempotent operations

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
| `azurerm_subnet_route_table_association` | The association between a subnet and route table |

## Prerequisites

Before using this module, you should have:

1. **Subnet** already created in a virtual network
2. **Route Table** already created in the same region
3. **Subnet ID** (full resource ID from the subnet module)
4. **Route Table ID** (full resource ID from the route-table module)
5. **Azure Subscription** with appropriate permissions

## Usage

### Basic Subnet Route Table Association

```hcl
module "subnet_route_table_assoc" {
  source = "./modules/route-table-subnet"
  
  subnet_id      = azurerm_subnet.example.id
  route_table_id = module.route_table.route_table_id
}
```

### Associate Route Table with Single Subnet

```hcl
# Create Route Table
module "route_table" {
  source = "./modules/route-table"
  
  name                = "rt-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  
  route = [
    {
      name                = "default-internet"
      address_prefix      = "0.0.0.0/0"
      next_hop_type       = "Internet"
      next_hop_ip_address = null
    }
  ]
  
  tags = {
    Environment = "Production"
  }
}

# Create Subnet
resource "azurerm_subnet" "workload" {
  name                 = "subnet-workload-eastus-001"
  resource_group_name  = module.resource_group.resource_group_name
  virtual_network_name = module.vnet.virtual_network_name
  address_prefixes     = ["10.0.1.0/24"]
}

# Associate Route Table with Subnet
module "route_table_association" {
  source = "./modules/route-table-subnet"
  
  subnet_id      = azurerm_subnet.workload.id
  route_table_id = module.route_table.route_table_id
}
```

### Associate Route Table with Multiple Subnets

```hcl
# Create Route Table
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
      next_hop_ip_address = "10.0.1.4"
    }
  ]
}

# Create Multiple Subnets
resource "azurerm_subnet" "workload_1" {
  name                 = "subnet-workload-1-eastus-001"
  resource_group_name  = module.resource_group.resource_group_name
  virtual_network_name = module.vnet.virtual_network_name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "workload_2" {
  name                 = "subnet-workload-2-eastus-001"
  resource_group_name  = module.resource_group.resource_group_name
  virtual_network_name = module.vnet.virtual_network_name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "workload_3" {
  name                 = "subnet-workload-3-eastus-001"
  resource_group_name  = module.resource_group.resource_group_name
  virtual_network_name = module.vnet.virtual_network_name
  address_prefixes     = ["10.0.3.0/24"]
}

# Associate Route Table with All Subnets
module "route_table_assoc_1" {
  source = "./modules/route-table-subnet"
  
  subnet_id      = azurerm_subnet.workload_1.id
  route_table_id = module.firewall_route_table.route_table_id
}

module "route_table_assoc_2" {
  source = "./modules/route-table-subnet"
  
  subnet_id      = azurerm_subnet.workload_2.id
  route_table_id = module.firewall_route_table.route_table_id
}

module "route_table_assoc_3" {
  source = "./modules/route-table-subnet"
  
  subnet_id      = azurerm_subnet.workload_3.id
  route_table_id = module.firewall_route_table.route_table_id
}
```

### Hub and Spoke with Selective Route Table Association

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

# Hub Firewall Subnet (no route table needed)
resource "azurerm_subnet" "hub_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = module.hub_rg.resource_group_name
  virtual_network_name = module.hub_vnet.virtual_network_name
  address_prefixes     = ["10.0.1.0/24"]
}

# Hub Gateway Subnet (no route table needed)
resource "azurerm_subnet" "hub_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = module.hub_rg.resource_group_name
  virtual_network_name = module.hub_vnet.virtual_network_name
  address_prefixes     = ["10.0.2.0/24"]
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

# Spoke Workload Subnet
resource "azurerm_subnet" "spoke_workload" {
  name                 = "subnet-workload-eastus-001"
  resource_group_name  = module.spoke_rg.resource_group_name
  virtual_network_name = module.spoke_vnet.virtual_network_name
  address_prefixes     = ["10.1.1.0/24"]
}

# Route Table for Spoke (routes through hub firewall)
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
      next_hop_ip_address = "10.0.1.4"
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

# Associate Route Table with Spoke Workload Subnet
module "spoke_route_table_assoc" {
  source = "./modules/route-table-subnet"
  
  subnet_id      = azurerm_subnet.spoke_workload.id
  route_table_id = module.spoke_route_table.route_table_id
}

output "hub_vnet_id" {
  value = module.hub_vnet.virtual_network_id
}

output "spoke_vnet_id" {
  value = module.spoke_vnet.virtual_network_id
}
```

### Dynamic Subnet Association Using for_each

```hcl
# Create Route Table
module "route_table" {
  source = "./modules/route-table"
  
  name                = "rt-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  
  route = [
    {
      name                = "default-internet"
      address_prefix      = "0.0.0.0/0"
      next_hop_type       = "Internet"
      next_hop_ip_address = null
    }
  ]
}

# Create Multiple Subnets
resource "azurerm_subnet" "workload" {
  for_each = {
    subnet_1 = "10.0.1.0/24"
    subnet_2 = "10.0.2.0/24"
    subnet_3 = "10.0.3.0/24"
  }
  
  name                 = "subnet-${each.key}-eastus-001"
  resource_group_name  = module.resource_group.resource_group_name
  virtual_network_name = module.vnet.virtual_network_name
  address_prefixes     = [each.value]
}

# Associate Route Table with All Subnets Using for_each
module "route_table_assoc" {
  for_each = azurerm_subnet.workload
  
  source = "./modules/route-table-subnet"
  
  subnet_id      = each.value.id
  route_table_id = module.route_table.route_table_id
}
```

### Different Route Tables for Different Subnets

```hcl
# Internet Route Table
module "internet_route_table" {
  source = "./modules/route-table"
  
  name                = "rt-internet-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  
  route = [
    {
      name                = "default-internet"
      address_prefix      = "0.0.0.0/0"
      next_hop_type       = "Internet"
      next_hop_ip_address = null
    }
  ]
}

# Firewall Route Table
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
      next_hop_ip_address = "10.0.1.4"
    }
  ]
}

# Web Tier Subnet (direct internet access)
resource "azurerm_subnet" "web_tier" {
  name                 = "subnet-web-eastus-001"
  resource_group_name  = module.resource_group.resource_group_name
  virtual_network_name = module.vnet.virtual_network_name
  address_prefixes     = ["10.0.1.0/24"]
}

# App Tier Subnet (through firewall)
resource "azurerm_subnet" "app_tier" {
  name                 = "subnet-app-eastus-001"
  resource_group_name  = module.resource_group.resource_group_name
  virtual_network_name = module.vnet.virtual_network_name
  address_prefixes     = ["10.0.2.0/24"]
}

# Web Tier Association (internet route table)
module "web_route_table_assoc" {
  source = "./modules/route-table-subnet"
  
  subnet_id      = azurerm_subnet.web_tier.id
  route_table_id = module.internet_route_table.route_table_id
}

# App Tier Association (firewall route table)
module "app_route_table_assoc" {
  source = "./modules/route-table-subnet"
  
  subnet_id      = azurerm_subnet.app_tier.id
  route_table_id = module.firewall_route_table.route_table_id
}
```

### Conditional Route Table Association

```hcl
variable "enable_routing" {
  description = "Enable route table association"
  type        = bool
  default     = true
}

module "route_table_assoc" {
  count = var.enable_routing ? 1 : 0
  
  source = "./modules/route-table-subnet"
  
  subnet_id      = azurerm_subnet.example.id
  route_table_id = module.route_table.route_table_id
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| subnet_id | The ID of the subnet to associate with the route table | `string` | Yes | n/a |
| route_table_id | The ID of the route table to associate with the subnet | `string` | Yes | n/a |

## Outputs

No outputs are defined for this module. The association resource itself manages the relationship.

## Association Behavior

### When Association is Created

1. **Route Table Applied** - All routes in the route table become active for the subnet
2. **Immediate Effect** - Changes take effect immediately (no deployment required)
3. **All Traffic Affected** - All outbound traffic from the subnet uses the routes
4. **System Routes** - System routes continue to apply based on route priority

### When Association is Updated

1. **Route Table Changed** - Switching to a different route table
2. **Immediate Transition** - Traffic immediately uses new route table
3. **No Downtime** - Existing connections may be affected

### When Association is Deleted

1. **Route Table Removed** - Routes no longer applied to subnet
2. **System Routes Used** - Azure default routing takes over
3. **Immediate Effect** - Changes take effect immediately

## Relationship Between Components

```
Subnet ──── (has one) ──── Route Table Association ──── (references) ──── Route Table
   │                                                            │
   └─────────── (applies routes via) ───────────────────────────┘
```

### Data Flow

```
Outbound Traffic from Subnet
         ↓
Route Table Association (active)
         ↓
Route Table (defines routes)
         ↓
Route Selection (longest prefix match)
         ↓
Next Hop Processing (Internet, Firewall, VPN, etc.)
         ↓
Destination Reached
```

## Subnet Considerations

### Single Association Per Subnet

- Each subnet can have **only one** active route table association
- Creating a new association replaces the previous one
- No error occurs; simply overwrites

### Replacing Associations

```hcl
# Original association (will be replaced)
module "route_table_assoc_old" {
  source = "./modules/route-table-subnet"
  
  subnet_id      = azurerm_subnet.example.id
  route_table_id = module.route_table_old.route_table_id
}

# New association (replaces old)
module "route_table_assoc_new" {
  source = "./modules/route-table-subnet"
  
  subnet_id      = azurerm_subnet.example.id
  route_table_id = module.route_table_new.route_table_id
}
```

### Disassociation

To remove a route table association, simply delete or remove the module from your Terraform configuration:

```hcl
# Remove or comment out the association module
# module "route_table_assoc" {
#   source = "./modules/route-table-subnet"
#   ...
# }
```

## Gateway Subnet Special Considerations

### No Route Table on Gateway Subnet

```hcl
# DO NOT associate route table with GatewaySubnet
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"  # Exact name required
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/27"]
}

# NO association here - GatewaySubnet doesn't support route tables
```

### No Route Table on Azure Firewall Subnet

```hcl
# DO NOT associate route table with AzureFirewallSubnet
resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"  # Exact name required
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

# NO association here - firewall subnet doesn't support route tables
```

## NAT Gateway Subnet Interaction

```hcl
# Subnet can have both NAT Gateway and Route Table
resource "azurerm_subnet" "workload" {
  name                 = "subnet-workload-eastus-001"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# NAT Gateway (for outbound SNAT)
resource "azurerm_nat_gateway" "example" {
  name                = "ng-prod-eastus-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

resource "azurerm_subnet_nat_gateway_association" "example" {
  subnet_id      = azurerm_subnet.workload.id
  nat_gateway_id = azurerm_nat_gateway.example.id
}

# Route Table (for custom routing)
module "route_table" {
  source = "./modules/route-table"
  
  name                = "rt-prod-eastus-001"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.example.name
  
  route = [
    {
      name                = "default-internet"
      address_prefix      = "0.0.0.0/0"
      next_hop_type       = "Internet"
      next_hop_ip_address = null
    }
  ]
}

# Both associations on same subnet (allowed)
module "route_table_assoc" {
  source = "./modules/route-table-subnet"
  
  subnet_id      = azurerm_subnet.workload.id
  route_table_id = module.route_table.route_table_id
}
```

## Naming Conventions

### Subnet Naming

Follow [Azure naming conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming):

- **Pattern**: `subnet-<application>-<environment>-<region>-<instance>`
- **Examples**:
  - `subnet-workload-prod-eastus-001`
  - `subnet-web-prod-eastus-001`
  - `subnet-app-prod-eastus-001`
  - `subnet-database-prod-eastus-001`

### Route Table Naming

- **Pattern**: `rt-<application>-<environment>-<region>-<instance>`
- **Examples**:
  - `rt-prod-eastus-001`
  - `rt-firewall-prod-eastus-001`
  - `rt-vpn-prod-eastus-001`

## Security Best Practices

1. **Explicit Routing** - Only associate necessary route tables
2. **Firewall Routing** - Route untrusted subnets through firewall
3. **Segmentation** - Different route tables for different security tiers
4. **Least Privilege** - Only routes needed for workload function
5. **Documentation** - Document routing policies for each subnet
6. **Testing** - Test routing before production deployment
7. **Monitoring** - Monitor effective routes on subnets
8. **Audit** - Regularly audit subnet-route table associations
9. **Change Control** - Use Terraform for all routing changes
10. **Backup** - Maintain Terraform state in version control

## Troubleshooting

### Common Issues

**Issue**: Association fails with "Subnet not found"
- **Solution**:
  1. Verify subnet ID is correct
  2. Ensure subnet exists in the correct resource group
  3. Check subscription context
  4. Verify subnet is in the same region as route table

**Issue**: Association fails with "Route Table not found"
- **Solution**:
  1. Verify route table ID is correct
  2. Ensure route table exists
  3. Check route table is in same region as subnet
  4. Verify subscription has access to route table

**Issue**: Changing association causes traffic disruption
- **Solution**:
  1. Test route changes in non-prod first
  2. Plan association changes during maintenance window
  3. Verify return routes are in place
  4. Have rollback plan ready

**Issue**: Routes not being applied to subnet
- **Solution**:
  1. Verify association exists (check Azure portal)
  2. Run `terraform apply` to ensure state is current
  3. Check route table contains expected routes
  4. Verify no other route tables are associated
  5. Check firewall/appliance is operational

### Validation Commands

```powershell
# Show route table association
az network vnet subnet show --name subnet-workload-eastus-001 \
  --vnet-name vnet-prod-eastus-001 \
  --resource-group rg-prod-001 \
  --query "routeTable"

# List subnets with route tables
az network vnet subnet list --vnet-name vnet-prod-eastus-001 \
  --resource-group rg-prod-001 \
  --query "[].{Name:name, RouteTable:routeTable}" --output table

# Get effective routes on subnet
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
terrascan scan -d ./modules/route-table-subnet -i terraform

# Lint check
tflint --init
tflint
```

## Notes

- **Simple Association** - This module only creates the association link
- **Idempotent** - Safe to apply multiple times
- **No Route Modification** - Module doesn't modify route table contents
- **Regional** - Route table must be in same region as subnet
- **Single Association** - One route table per subnet (replaces previous)
- **Immediate Effect** - Changes take effect immediately
- **No Deletion Risk** - Deleting association doesn't delete route table
- **Cost** - No additional cost for associations

## Module Maintenance

### Version History

- **v1.0.0** - Initial release
  - Subnet route table association creation
  - Clean abstraction for relationship management

### Contributing

When contributing to this module:
1. Run `terraform fmt` to format code
2. Run `terraform validate` to check syntax
3. Test with different subnet types
4. Verify association creation and deletion
5. Test with multiple subnets
6. Run security scans with Terrascan or tfsec
7. Update documentation for any changes

## References

- [Azure Route Table Subnet Association Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/manage-route-table)
- [Subnet Route Table Association](https://learn.microsoft.com/en-us/azure/virtual-network/manage-route-table#associate-a-route-table-to-a-subnet)
- [Effective Routes](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview#effective-routes)
- [Terraform AzureRM Subnet Route Table Association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association)
- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Hub and Spoke Network Architecture](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
