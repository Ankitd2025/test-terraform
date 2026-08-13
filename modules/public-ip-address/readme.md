# Azure Public IP Address Module

This Terraform module creates an Azure Public IP Address with configurable SKU, allocation method, availability zones, and DDoS protection settings.

## Description

Azure Public IP addresses enable Azure resources to communicate with the internet and public-facing Azure services. This module simplifies the creation of public IP addresses with support for both Basic and Standard SKUs, static and dynamic allocation, zone redundancy, and DDoS protection.

## Features

- ✅ Support for Basic and Standard SKUs
- ✅ Static and Dynamic IP allocation methods
- ✅ Availability zone support for high availability
- ✅ DDoS protection mode configuration
- ✅ IPv4 support
- ✅ Comprehensive tagging support
- ✅ Output of assigned IP address for reference

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

| Resource Type | Description | Resource Name |
|--------------|-------------|----------------|
| `azurerm_public_ip` | The public IP address resource | `azurerm_public_ip` |
| `azurerm_monitor_diagnostic_setting` | Diagnostic setting (created only if `enable_diagnostic = true`) | `azurerm_monitor_diagnostic_setting` |

> **Note**: The diagnostic setting is created conditionally using `count = var.enable_diagnostic ? 1 : 0`. If diagnostics are not enabled, no diagnostic setting resource is created.

## Usage

### Standard SKU with Static IP (Recommended for Production)

```hcl
module "public_ip" {
  source = "./modules/public-ip-address"
  
  name                 = "pip-bastion-prod-eastus-001"
  location             = "eastus"
  resource_group_name  = module.resource_group.resource_group_name
  allocation_method    = "Static"
  sku                  = "Standard"
  zones                = ["1", "2", "3"]  # Zone-redundant
  ddos_protection_mode = "VirtualNetworkInherited"
  
  tags = {
    Environment = "Production"
    Service     = "Bastion"
    ManagedBy   = "Terraform"
  }
}
```

### Basic SKU with Dynamic IP

```hcl
module "public_ip_basic" {
  source = "./modules/public-ip-address"
  
  name                 = "pip-dev-vm-eastus-001"
  location             = "eastus"
  resource_group_name  = module.resource_group.resource_group_name
  allocation_method    = "Dynamic"
  sku                  = "Basic"
  zones                = []  # Basic SKU doesn't support zones
  ddos_protection_mode = "VirtualNetworkInherited"
  
  tags = {
    Environment = "Development"
    Purpose     = "Testing"
    ManagedBy   = "Terraform"
  }
}
```

### Standard SKU with Enabled DDoS Protection

```hcl
module "public_ip_ddos" {
  source = "./modules/public-ip-address"
  
  name                 = "pip-webapp-prod-eastus-001"
  location             = "eastus"
  resource_group_name  = module.resource_group.resource_group_name
  allocation_method    = "Static"
  sku                  = "Standard"
  zones                = ["1", "2", "3"]
  ddos_protection_mode = "Enabled"  # Requires DDoS Protection Plan
  
  tags = {
    Environment = "Production"
    Service     = "WebApp"
    Protection  = "DDoS"
    ManagedBy   = "Terraform"
  }
}
```

### Zone-Specific Public IP

```hcl
module "public_ip_zone1" {
  source = "./modules/public-ip-address"
  
  name                 = "pip-appgw-prod-eastus-001"
  location             = "eastus"
  resource_group_name  = module.resource_group.resource_group_name
  allocation_method    = "Static"
  sku                  = "Standard"
  zones                = ["1"]  # Deployed to specific zone
  ddos_protection_mode = "VirtualNetworkInherited"
  
  tags = {
    Environment = "Production"
    Service     = "ApplicationGateway"
    Zone        = "1"
    ManagedBy   = "Terraform"
  }
}
```

### Complete Example with Multiple Public IPs

```hcl
locals {
  common_tags = {
    Environment = "Production"
    Project     = "IncumbentFI"
    ManagedBy   = "Terraform"
  }
}

# Public IP for Azure Bastion
module "pip_bastion" {
  source = "./modules/public-ip-address"
  
  name                 = "pip-bastion-prod-eastus-001"
  location             = "eastus"
  resource_group_name  = module.resource_group.resource_group_name
  allocation_method    = "Static"
  sku                  = "Standard"
  zones                = ["1", "2", "3"]
  ddos_protection_mode = "VirtualNetworkInherited"
  
  tags = merge(local.common_tags, {
    Service = "Bastion"
  })
}

# Public IP for Application Gateway
module "pip_appgw" {
  source = "./modules/public-ip-address"
  
  name                 = "pip-appgw-prod-eastus-001"
  location             = "eastus"
  resource_group_name  = module.resource_group.resource_group_name
  allocation_method    = "Static"
  sku                  = "Standard"
  zones                = ["1", "2", "3"]
  ddos_protection_mode = "VirtualNetworkInherited"
  
  tags = merge(local.common_tags, {
    Service = "ApplicationGateway"
  })
}

# Public IP for VPN Gateway
module "pip_vpn" {
  source = "./modules/public-ip-address"
  
  name                 = "pip-vpn-prod-eastus-001"
  location             = "eastus"
  resource_group_name  = module.resource_group.resource_group_name
  allocation_method    = "Static"
  sku                  = "Standard"
  zones                = ["1", "2", "3"]
  ddos_protection_mode = "VirtualNetworkInherited"
  
  tags = merge(local.common_tags, {
    Service = "VPNGateway"
  })
}

# Public IP for Load Balancer
module "pip_lb" {
  source = "./modules/public-ip-address"
  
  name                 = "pip-lb-prod-eastus-001"
  location             = "eastus"
  resource_group_name  = module.resource_group.resource_group_name
  allocation_method    = "Static"
  sku                  = "Standard"
  zones                = ["1", "2", "3"]
  ddos_protection_mode = "VirtualNetworkInherited"
  
  tags = merge(local.common_tags, {
    Service = "LoadBalancer"
  })
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | The name of the public IP address | `string` | Yes | n/a |
| location | The Azure region where the public IP will be created | `string` | Yes | n/a |
| resource_group_name | The name of the resource group | `string` | Yes | n/a |
| allocation_method | Allocation method: `Static` or `Dynamic` | `string` | Yes | n/a |
| sku | The SKU: `Basic` or `Standard` | `string` | Yes | n/a |
| zones | List of availability zones (e.g., `["1", "2", "3"]` for zone-redundant, `["1"]` for zonal, `[]` for non-zonal) | `list(string)` | Yes | n/a |
| ddos_protection_mode | DDoS protection mode: `Disabled`, `Enabled`, or `VirtualNetworkInherited` | `string` | Yes | n/a |
| tags | A map of tags to assign to the public IP address | `map(string)` | Yes | n/a || enable_diagnostic | Whether to enable diagnostics for the public IP address | `bool` | Yes | n/a |
| log_analytics_workspace_id | The ID of the Log Analytics workspace to send diagnostics to (required if `enable_diagnostic = true`) | `string` | Yes (if enable_diagnostic = true) | n/a |
## Outputs

| Name | Description |
|------|-------------|
| public_ip_address_id | The ID of the public IP address |
| public_ip_address_name | The name of the public IP address |
| public_ip_address_ip_address | The actual IP address value (empty for Dynamic until assigned) |

## Azure Naming Conventions

When naming public IP addresses, follow [Azure naming conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming):

- **Length**: 1-80 characters
- **Valid characters**: Alphanumerics, underscores, periods, and hyphens
- **Start with**: Alphanumeric
- **End with**: Alphanumeric or underscore
- **Recommended pattern**: `pip-<service>-<environment>-<region>-<instance>`

### Examples

- `pip-bastion-prod-eastus-001` (Azure Bastion)
- `pip-appgw-prod-eastus-001` (Application Gateway)
- `pip-vpn-prod-eastus-001` (VPN Gateway)
- `pip-lb-prod-eastus-001` (Load Balancer)
- `pip-fw-prod-eastus-001` (Azure Firewall)
- `pip-vm-web-prod-eastus-001` (Virtual Machine)

## SKU Comparison

### Basic SKU

**Characteristics:**
- ✅ Dynamic or Static IP allocation
- ✅ IPv4 support
- ✅ Open by default (NSG recommended)
- ❌ No availability zone support
- ❌ Not zone-redundant
- ❌ Limited to Basic Load Balancer
- ❌ No DDoS Protection Standard support

**Best for:** Development, test, or non-critical workloads

**Compatibility:**
- Basic Load Balancer
- Basic VPN Gateway
- VMs without zone requirements

### Standard SKU

**Characteristics:**
- ✅ Static IP allocation only
- ✅ IPv4 support
- ✅ Secure by default (closed inbound)
- ✅ Availability zone support
- ✅ Zone-redundant option
- ✅ Compatible with Standard Load Balancer
- ✅ DDoS Protection Standard support
- ✅ Higher SLA

**Best for:** Production workloads requiring high availability

**Compatibility:**
- Standard Load Balancer
- Application Gateway v2
- VPN Gateway (VpnGw1AZ and higher)
- Azure Bastion
- Azure Firewall
- Zone-redundant services

## Allocation Methods

### Static Allocation

**Characteristics:**
- IP address assigned immediately upon creation
- IP address never changes (unless resource is deleted)
- Required for Standard SKU
- Recommended for production services
- Supports DNS hostname assignment
- Required for SSL certificates bound to IP

**Use cases:**
- Production web applications
- Services requiring DNS A records
- SSL/TLS certificates bound to IP
- Services requiring IP whitelisting
- Azure Bastion, Application Gateway, Firewall

### Dynamic Allocation

**Characteristics:**
- IP address assigned when associated with resource
- IP address released when resource is stopped/deallocated
- Only available with Basic SKU
- IP may change after deallocation
- Lower consistency for external access

**Use cases:**
- Development/test environments
- Non-critical workloads
- Resources that are frequently deallocated
- Temporary VMs

## Availability Zones

### Zone-Redundant Configuration

Deploy across multiple zones for high availability:

```hcl
zones = ["1", "2", "3"]  # Replicated across all zones
```

**Benefits:**
- Survives zone failures
- 99.99% SLA for zone-redundant Standard Public IPs
- Automatic failover

**Use cases:**
- Production workloads
- Business-critical applications
- Services requiring maximum uptime

### Zonal Configuration

Deploy to a specific zone:

```hcl
zones = ["1"]  # Pinned to zone 1
```

**Benefits:**
- Collocated with zone-specific resources
- Lower latency within zone
- Explicit control over placement

**Use cases:**
- Resources pinned to specific zones
- Zone-specific architectures
- Performance-sensitive applications

### Non-Zonal (Regional)

No zone specification:

```hcl
zones = []  # Regional, no zone guarantee
```

**Characteristics:**
- No zone guarantees
- May be placed in any zone
- Basic SKU default

**Use cases:**
- Basic SKU deployments
- Regions without availability zones
- Non-critical workloads

## DDoS Protection Modes

### VirtualNetworkInherited (Recommended)

```hcl
ddos_protection_mode = "VirtualNetworkInherited"
```

**Characteristics:**
- Inherits DDoS protection from the VNet
- If VNet has DDoS Protection Plan, IP is protected
- If VNet has Basic protection, IP has Basic protection
- No additional per-IP cost
- Most flexible option

**Best for:** Most scenarios

### Enabled

```hcl
ddos_protection_mode = "Enabled"
```

**Characteristics:**
- Always protected by DDoS Protection Standard
- Requires DDoS Protection Plan in subscription
- Provides comprehensive DDoS mitigation
- Advanced monitoring and analytics

**Requirements:**
- Standard SKU only
- DDoS Protection Plan must exist
- Additional costs apply

**Best for:** Critical public-facing services requiring guaranteed DDoS protection

### Disabled

```hcl
ddos_protection_mode = "Disabled"
```

**Characteristics:**
- No DDoS protection
- Only Basic DDoS protection provided by Azure platform

**Not recommended for production workloads**

## Common Use Cases

### Azure Bastion

```hcl
module "pip_bastion" {
  source = "./modules/public-ip-address"
  
  name                 = "pip-bastion-prod-eastus-001"
  location             = "eastus"
  resource_group_name  = module.resource_group.resource_group_name
  allocation_method    = "Static"      # Required for Bastion
  sku                  = "Standard"    # Required for Bastion
  zones                = ["1", "2", "3"]
  ddos_protection_mode = "VirtualNetworkInherited"
  tags                 = local.common_tags
}
```

### Application Gateway v2

```hcl
module "pip_appgw" {
  source = "./modules/public-ip-address"
  
  name                 = "pip-appgw-prod-eastus-001"
  location             = "eastus"
  resource_group_name  = module.resource_group.resource_group_name
  allocation_method    = "Static"      # Required for App Gateway v2
  sku                  = "Standard"    # Required for App Gateway v2
  zones                = ["1", "2", "3"]
  ddos_protection_mode = "VirtualNetworkInherited"
  tags                 = local.common_tags
}
```

### Azure Firewall

```hcl
module "pip_firewall" {
  source = "./modules/public-ip-address"
  
  name                 = "pip-fw-prod-eastus-001"
  location             = "eastus"
  resource_group_name  = module.resource_group.resource_group_name
  allocation_method    = "Static"      # Required for Firewall
  sku                  = "Standard"    # Required for Firewall
  zones                = ["1", "2", "3"]
  ddos_protection_mode = "VirtualNetworkInherited"
  tags                 = local.common_tags
}
```

### VPN Gateway (Zone-Redundant)

```hcl
module "pip_vpn" {
  source = "./modules/public-ip-address"
  
  name                 = "pip-vpn-prod-eastus-001"
  location             = "eastus"
  resource_group_name  = module.resource_group.resource_group_name
  allocation_method    = "Static"      # Recommended for VPN
  sku                  = "Standard"    # Required for zone-redundant VPN Gateway
  zones                = ["1", "2", "3"]
  ddos_protection_mode = "VirtualNetworkInherited"
  tags                 = local.common_tags
}
```

### Standard Load Balancer

```hcl
module "pip_lb" {
  source = "./modules/public-ip-address"
  
  name                 = "pip-lb-prod-eastus-001"
  location             = "eastus"
  resource_group_name  = module.resource_group.resource_group_name
  allocation_method    = "Static"
  sku                  = "Standard"    # Required for Standard LB
  zones                = ["1", "2", "3"]
  ddos_protection_mode = "VirtualNetworkInherited"
  tags                 = local.common_tags
}
```

### NAT Gateway

```hcl
module "pip_nat" {
  source = "./modules/public-ip-address"
  
  name                 = "pip-nat-prod-eastus-001"
  location             = "eastus"
  resource_group_name  = module.resource_group.resource_group_name
  allocation_method    = "Static"
  sku                  = "Standard"    # Required for NAT Gateway
  zones                = ["1", "2", "3"]
  ddos_protection_mode = "VirtualNetworkInherited"
  tags                 = local.common_tags
}
```

### Development VM (Basic SKU)

```hcl
module "pip_dev_vm" {
  source = "./modules/public-ip-address"
  
  name                 = "pip-vm-dev-eastus-001"
  location             = "eastus"
  resource_group_name  = module.resource_group.resource_group_name
  allocation_method    = "Dynamic"     # Acceptable for dev/test
  sku                  = "Basic"       # Lower cost for dev/test
  zones                = []
  ddos_protection_mode = "VirtualNetworkInherited"
  
  tags = {
    Environment = "Development"
    Purpose     = "Testing"
    ManagedBy   = "Terraform"
  }
}
```

## SKU and Service Compatibility Matrix

| Azure Service | Supported SKU | Required Allocation | Zone Support |
|--------------|---------------|---------------------|--------------|
| Azure Bastion | Standard | Static | Yes |
| Application Gateway v2 | Standard | Static | Yes |
| Application Gateway v1 | Basic, Standard | Static | No |
| Azure Firewall | Standard | Static | Yes |
| VPN Gateway (zone-redundant) | Standard | Static | Yes |
| VPN Gateway (basic) | Basic | Dynamic/Static | No |
| Standard Load Balancer | Standard | Static | Yes |
| Basic Load Balancer | Basic | Dynamic/Static | No |
| NAT Gateway | Standard | Static | Yes |
| Virtual Machines | Basic, Standard | Dynamic/Static | Standard only |

## Security Best Practices

1. **Use Standard SKU for Production**: Provides secure by default configuration
2. **Always Use Static for Services**: Prevents IP changes and service disruptions
3. **Enable Zone Redundancy**: Deploy across availability zones for high availability
4. **Use VirtualNetworkInherited DDoS**: Leverages VNet-level DDoS protection
5. **Apply NSGs**: Restrict inbound access to public IPs (especially Basic SKU)
6. **Tag Resources**: Maintain clear resource identification and ownership
7. **Limit Basic SKU**: Use only for development/test environments
8. **Monitor Usage**: Track public IP usage and costs via Azure Monitor
9. **Use Just-in-Time Access**: For VM public IPs, enable JIT access
10. **Regular Audits**: Review and remove unused public IPs

## Monitoring and Diagnostics

### Enabling Diagnostic Settings

The module supports optional diagnostic logging to a Log Analytics workspace. To enable diagnostics, set the `enable_diagnostic` variable to `true` and provide a `log_analytics_workspace_id`.

**Example with diagnostics enabled:**

```hcl
module "public_ip" {
  source = "./modules/public-ip-address"
  
  name                        = "pip-bastion-prod-eastus-001"
  location                    = "eastus"
  resource_group_name         = module.resource_group.resource_group_name
  allocation_method           = "Static"
  sku                         = "Standard"
  zones                       = ["1", "2", "3"]
  ddos_protection_mode        = "VirtualNetworkInherited"
  enable_diagnostic           = true
  log_analytics_workspace_id  = module.log_analytics.id
  
  tags = {
    Environment = "Production"
    Service     = "Bastion"
    ManagedBy   = "Terraform"
  }
}
```

**Example with diagnostics disabled:**

```hcl
module "public_ip" {
  source = "./modules/public-ip-address"
  
  name                        = "pip-vm-dev-eastus-001"
  location                    = "eastus"
  resource_group_name         = module.resource_group.resource_group_name
  allocation_method           = "Dynamic"
  sku                         = "Basic"
  zones                       = []
  ddos_protection_mode        = "VirtualNetworkInherited"
  enable_diagnostic           = false
  log_analytics_workspace_id  = ""
  
  tags = {
    Environment = "Development"
    Purpose     = "Testing"
    ManagedBy   = "Terraform"
  }
}
```

### Diagnostic Setting Details

When diagnostics are enabled, the module creates an `azurerm_monitor_diagnostic_setting` resource that:

- **Name**: Automatically generated as `diag-{public-ip-name}`
- **Target Resource**: The public IP address resource
- **Logs**: All log categories are enabled (`allLogs`)
- **Metrics**: All metrics are captured (`AllMetrics`)
- **Destination**: Sends data to the specified Log Analytics workspace

### Diagnostic Setting Configuration

```hcl
resource "azurerm_monitor_diagnostic_setting" "azurerm_monitor_diagnostic_setting" {
  count                      = var.enable_diagnostic ? 1 : 0
  name                       = "diag-${azurerm_public_ip.azurerm_public_ip.name}"
  target_resource_id         = azurerm_public_ip.azurerm_public_ip.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
```

### Log Analytics Workspace Example

```hcl
module "log_analytics" {
  source = "./modules/log-analytics-workspaces"
  
  name                = "law-incumbentfi-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Key Metrics to Monitor

- **Bytes In/Out**: Network traffic volume
- **Packets In/Out**: Packet counts
- **VIP Availability**: Public IP availability (Standard SKU)
- **Inbound SYN Packets to Trigger DDoS Mitigation**: DDoS attack indicators (if DDoS Protection enabled)
- **Inbound TCP/UDP Packets DDoS**: DDoS-related packet counts (if DDoS Protection enabled)

### Querying Diagnostic Data in Log Analytics

**Find all Public IP activity:**

```kusto
AzureDiagnostics
| where ResourceType == "PUBLICIPADDRESSES"
| project TimeGenerated, OperationName, ResultDescription
```

**Monitor network traffic:**

```kusto
AzureDiagnostics
| where ResourceType == "PUBLICIPADDRESSES"
| summarize TotalBytes = sum(tolong(BytesReceived) + tolong(BytesSent)) by bin(TimeGenerated, 5m)
```

**Track DDoS attacks (if DDoS Protection enabled):**

```kusto
AzureDiagnostics
| where ResourceType == "PUBLICIPADDRESSES"
| where OperationName contains "DDoS"
| project TimeGenerated, OperationName, ResultDescription
```

## Troubleshooting

### Common Issues

**Issue**: Cannot create Standard SKU with Dynamic allocation
- **Solution**: Standard SKU only supports Static allocation. Change `allocation_method = "Static"`.

**Issue**: Cannot use zones with Basic SKU
- **Solution**: Basic SKU doesn't support availability zones. Either use Standard SKU or set `zones = []`.

**Issue**: Public IP not appearing on VM
- **Solution**: 
  1. For Dynamic IPs, ensure the resource (VM/NIC) is started
  2. Dynamic IPs are only assigned when the resource is running
  3. Check that the public IP is associated with a network interface

**Issue**: DDoS protection mode "Enabled" fails
- **Solution**: 
  1. Ensure you're using Standard SKU (required for DDoS Enabled)
  2. Verify a DDoS Protection Plan exists in the subscription
  3. Use "VirtualNetworkInherited" for most scenarios

**Issue**: Cannot attach Basic SKU public IP to Standard Load Balancer
- **Solution**: Standard Load Balancer requires Standard SKU public IPs. Recreate with `sku = "Standard"`.

**Issue**: Public IP address not in expected zone
- **Solution**: Verify `zones` parameter is correctly set. Empty list means no zone guarantee.

**Issue**: IP address shows as empty in Terraform output
- **Solution**: For Dynamic IPs, the address is only assigned when attached to a running resource. Check after resource is started.

### Validation Commands

```powershell
# Show public IP details
az network public-ip show --name <pip-name> --resource-group <rg-name>

# List all public IPs in resource group
az network public-ip list --resource-group <rg-name> --output table

# Check IP address value
az network public-ip show --name <pip-name> --resource-group <rg-name> --query ipAddress

# Check SKU and allocation method
az network public-ip show --name <pip-name> --resource-group <rg-name> \
  --query "{SKU:sku.name, Allocation:publicIpAllocationMethod, Zones:zones}"

# List unused public IPs (not associated)
az network public-ip list --query "[?ipConfiguration==null].{Name:name, ResourceGroup:resourceGroup}" --output table

# Update public IP (e.g., add tags)
az network public-ip update --name <pip-name> --resource-group <rg-name> --tags Environment=Production

# Delete public IP
az network public-ip delete --name <pip-name> --resource-group <rg-name>

# Terraform validation
terraform init
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
terrascan scan -d .\modules\public-ip-address\ -i terraform
```

## Notes

- Standard SKU public IPs are **secure by default** (inbound traffic blocked until NSG allows)
- Basic SKU public IPs are **open by default** (NSG strongly recommended)
- Dynamic IP addresses are **only assigned** when attached to a running resource
- Static IP addresses are **assigned immediately** upon creation
- You are **charged for unused** static public IPs
- Standard SKU requires **Static allocation** (Dynamic not supported)
- Availability zones are **only supported** with Standard SKU
- Zone-redundant IPs have **99.99% SLA** vs 99.9% for zonal/regional
- Public IPs **cannot be moved** between regions after creation
- DDoS Protection "Enabled" mode requires **DDoS Protection Plan** (additional cost)
- Basic and Standard SKU resources **cannot be mixed** (e.g., Basic IP + Standard LB)
- **IP address changes** when moving from Dynamic to Static (requires recreation)
- Maximum **1000 public IPs per subscription per region** (soft limit, can be increased)

## Module Maintenance

### Version History

- **v1.0.0** - Initial release
  - Public IP address creation with configurable parameters
  - Support for Basic and Standard SKUs
  - Static and Dynamic allocation methods
  - Availability zone support
  - DDoS protection mode configuration
  - Comprehensive tagging support
  - Output of IP address value

### Contributing

When contributing to this module:
1. Run `terraform fmt` to format code
2. Run `terraform validate` to check syntax
3. Test with both Basic and Standard SKUs
4. Verify Static and Dynamic allocation methods
5. Test zone-redundant and zonal configurations
6. Verify DDoS protection modes
7. Test with different Azure services (Bastion, App Gateway, etc.)
8. Run security scans with Terrascan or tfsec
9. Update documentation for any new variables or outputs
10. Test in non-production environment first

## References

- [Azure Public IP Addresses Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses)
- [Public IP SKU](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses#sku)
- [Availability Zones Support](https://learn.microsoft.com/en-us/azure/reliability/availability-zones-overview)
- [DDoS Protection](https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview)
- [Public IP Prefix](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-address-prefix)
- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Public IP Allocation Method](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses#allocation-method)
- [Standard Public IP and Load Balancer](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-standard-availability-zones)
- [Terraform AzureRM Provider - Public IP](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip)
- [Azure Public IP SLA](https://azure.microsoft.com/en-us/support/legal/sla/virtual-network/)