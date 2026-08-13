# Azure Virtual Network Module

This Terraform module creates an Azure Virtual Network with optional diagnostic settings for comprehensive network monitoring and security compliance.

## Description

An Azure Virtual Network (VNet) is the fundamental building block for your private network in Azure. This module provisions a virtual network with configurable address space and includes optional diagnostic settings for VM Protection Alerts and metrics monitoring.

## Features

- ✅ Configurable virtual network with custom address space
- ✅ Optional diagnostic settings with Log Analytics integration
- ✅ VM Protection Alerts monitoring
- ✅ AllMetrics monitoring capability
- ✅ Tag support for resource organization
- ✅ Standardized naming convention support

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Usage

### Basic Virtual Network

```hcl
module "virtual_network" {
  source = "./modules/virtual-network"
  
  name                       = "vnet-incumbentfi-prod-eastus-001"
  address_space              = ["10.0.0.0/16"]
  location                   = "eastus"
  resource_group_name        = "rg-incumbentfi-prod-eastus-001"
  enable_diagnostic          = false
  enable_flow_log            = false
  log_analytics_workspace_id = ""
  
  tags = {
    Environment = "Production"
    Project     = "IncumbentFI"
    ManagedBy   = "Terraform"
  }
}
```

### Virtual Network with Diagnostic Settings

```hcl
module "virtual_network" {
  source = "./modules/virtual-network"
  
  name                       = "vnet-incumbentfi-prod-eastus-001"
  address_space              = ["10.0.0.0/16"]
  location                   = "eastus"
  resource_group_name        = module.resource_group.resource_group_name
  enable_diagnostic          = true
  enable_flow_log            = false
  log_analytics_workspace_id = module.log_analytics.id
  
  tags = {
    Environment        = "Production"
    Project            = "IncumbentFI"
    ManagedBy          = "Terraform"
    SecurityMonitoring = "Enabled"
  }
}
```

### Multi-Region Virtual Networks

```hcl
# East US Virtual Network
module "vnet_east" {
  source = "./modules/virtual-network"
  
  name                       = "vnet-incumbentfi-prod-eastus-001"
  address_space              = ["10.0.0.0/16"]
  location                   = "eastus"
  resource_group_name        = module.rg_east.resource_group_name
  enable_diagnostic          = true
  enable_flow_log            = false
  log_analytics_workspace_id = module.log_analytics_east.id
  
  tags = local.common_tags
}

# West US Virtual Network
module "vnet_west" {
  source = "./modules/virtual-network"
  
  name                       = "vnet-incumbentfi-prod-westus-001"
  address_space              = ["10.1.0.0/16"]
  location                   = "westus"
  resource_group_name        = module.rg_west.resource_group_name
  enable_diagnostic          = true
  enable_flow_log            = false
  log_analytics_workspace_id = module.log_analytics_west.id
  
  tags = local.common_tags
}
```

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
| `azurerm_virtual_network` | The main virtual network resource |
| `azurerm_monitor_diagnostic_setting` | Diagnostic settings (when `enable_diagnostic = true`) |

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | The name of the virtual network | `string` | Yes | n/a |
| address_space | The address space of the virtual network (CIDR blocks) | `list(string)` | Yes | n/a |
| location | The Azure region where the virtual network will be created | `string` | Yes | n/a |
| resource_group_name | The name of the resource group in which to create the virtual network | `string` | Yes | n/a |
| tags | A map of tags to assign to the resources | `map(string)` | Yes | n/a |
| enable_diagnostic | Whether to enable diagnostic settings for the virtual network | `bool` | No | `false` |
| enable_flow_log | Whether to enable flow logs for the virtual network (reserved for future use) | `bool` | No | `false` |
| log_analytics_workspace_id | The ID of the Log Analytics workspace for diagnostic settings | `string` | Yes* | n/a |

\* Required only when `enable_diagnostic = true`

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the virtual network |
| name | The name of the virtual network |
| location | The location of the virtual network |
| resource_group_name | The name of the resource group in which the virtual network is created |

## Azure Naming Conventions

When naming virtual networks, follow [Azure naming conventions](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules):

- **Length**: 2-64 characters
- **Valid characters**: Alphanumerics, underscores, periods, and hyphens
- **Start with**: Alphanumeric
- **End with**: Alphanumeric or underscore
- **Recommended pattern**: `vnet-<application>-<environment>-<region>-<instance>`

### Examples

- `vnet-incumbentfi-prod-eastus-001`
- `vnet-incumbentfi-dev-westus2-001`
- `vnet-shared-services-prod-centralus-001`

## Network Planning Best Practices

### Address Space Planning

- **Non-overlapping**: Ensure address spaces don't overlap with other VNets or on-premises networks
- **Future growth**: Allocate sufficient address space for future expansion
- **Subnet allocation**: Plan subnet sizes based on workload requirements
- **Azure reserved IPs**: Azure reserves 5 IP addresses in each subnet

### Common Address Space Patterns

```hcl
# Small organization (single region)
address_space = ["10.0.0.0/16"]  # 65,536 addresses

# Medium organization (multi-region)
address_space = ["10.0.0.0/16"]  # Region 1
address_space = ["10.1.0.0/16"]  # Region 2
address_space = ["10.2.0.0/16"]  # Region 3

# Large organization with hub-spoke
address_space = ["10.0.0.0/16"]  # Hub VNet
address_space = ["10.10.0.0/16"] # Spoke VNet 1
address_space = ["10.20.0.0/16"] # Spoke VNet 2
```

## Diagnostic Settings

### Log Analytics Integration

When `enable_diagnostic = true`, the module sends diagnostic data to Azure Log Analytics workspace for advanced querying, alerting, and visualization.

### What Gets Monitored

The module captures and sends to Log Analytics:

- **VMProtectionAlerts**: Alerts related to VM protection features
- **AllMetrics**: All available metrics for the virtual network including:
  - Bytes and packets transmitted/received
  - Packets dropped by DDoS protection
  - Available IP addresses in subnets
  - Virtual Network peering metrics

### Log Analytics Benefits

- **Advanced Querying**: Use KQL (Kusto Query Language) to analyze network metrics and alerts
- **Custom Dashboards**: Create visualizations and dashboards in Azure Monitor workbooks
- **Alerting**: Set up intelligent alerts based on metric thresholds and patterns
- **Long-term Retention**: Store diagnostic data for extended periods for compliance
- **Integration**: Combine with other Azure service logs for comprehensive monitoring
- **Azure Sentinel**: Feed data into Azure Sentinel for security analytics

### Use Cases

- Monitor network performance and health with real-time queries
- Track resource utilization trends over time
- Compliance and audit requirements with queryable logs
- Troubleshooting network issues with detailed diagnostic data
- Security monitoring and threat detection when integrated with Sentinel
- Capacity planning by analyzing IP address utilization

## Network Flow Logs

> **Note**: Network Flow Logs are not currently implemented in this module. The `enable_flow_log` variable is reserved for future functionality. To enable flow logs for your virtual network, you must configure NSG Flow Logs separately on the Network Security Groups associated with your subnets.

For current flow logging requirements, consider:
- Implementing NSG Flow Logs on subnet-level Network Security Groups
- Using the separate `network-watchers` module for centralized flow log management
- Configuring Azure Network Watcher directly for flow log capabilities

## Security and Compliance

### Security Best Practices

1. **Network Segmentation**: Use separate VNets for different environments (dev, test, prod)
2. **Diagnostic Monitoring**: Enable diagnostics for security monitoring and alerting
3. **Network Security Groups**: Always use NSGs with subnets to control traffic flow
4. **Service Endpoints**: Use VNet service endpoints for Azure PaaS services
5. **Private Endpoints**: Use Private Link for enhanced security and private connectivity
6. **DDoS Protection**: Consider enabling Azure DDoS Protection Standard for production workloads

### Compliance Requirements

Diagnostic settings help meet compliance requirements for:
- **PCI-DSS**: Network monitoring requirements
- **HIPAA**: Access logging and monitoring
- **SOC 2**: Security monitoring controls
- **ISO 27001**: Information security management

For enhanced compliance (flow logging), implement NSG Flow Logs separately on Network Security Groups.

### Compliance Scanning

Scan this module for security and compliance:

```powershell
terrascan scan -d .\modules\virtual-network\ -i terraform
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

# Security scan
terrascan scan -d .\modules\virtual-network\ -i terraform

# Format code
terraform fmt -recursive
```
## Advanced Usage

### Complete Monitoring Setup with Log Analytics

```hcl
# Create Log Analytics workspace for centralized monitoring
resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "law-incumbentfi-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  
  tags = local.common_tags
}

# Create virtual network with diagnostic monitoring enabled
module "virtual_network" {
  source = "./modules/virtual-network"
  
  name                       = "vnet-incumbentfi-prod-eastus-001"
  address_space              = ["10.0.0.0/16"]
  location                   = "eastus"
  resource_group_name        = module.resource_group.resource_group_name
  enable_diagnostic          = true
  enable_flow_log            = false
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id
  
  tags = local.common_tags
}
```

### Hub-Spoke Topology

```hcl
# Hub VNet with shared services
module "hub_vnet" {
  source = "./modules/virtual-network"
  
  name                       = "vnet-hub-prod-eastus-001"
  address_space              = ["10.0.0.0/16"]
  location                   = "eastus"
  resource_group_name        = module.hub_rg.resource_group_name
  enable_diagnostic          = true
  enable_flow_log            = false
  log_analytics_workspace_id = module.log_analytics.id
  
  tags = merge(local.common_tags, {
    VNetType = "Hub"
  })
}

# Spoke VNet for application workloads
module "spoke_vnet" {
  source = "./modules/virtual-network"
  
  name                       = "vnet-spoke-app-prod-eastus-001"
  address_space              = ["10.10.0.0/16"]
  location                   = "eastus"
  resource_group_name        = module.spoke_rg.resource_group_name
  enable_diagnostic          = true
  enable_flow_log            = false
  log_analytics_workspace_id = module.log_analytics.id
  
  tags = merge(local.common_tags, {
    VNetType = "Spoke"
    Workload = "Application"
  })
}

# VNet Peering (defined separately)
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "peer-hub-to-spoke"
  resource_group_name       = module.hub_rg.resource_group_name
  virtual_network_name      = module.hub_vnet.name
  remote_virtual_network_id = module.spoke_vnet.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "peer-spoke-to-hub"
  resource_group_name       = module.spoke_rg.resource_group_name
  virtual_network_name      = module.spoke_vnet.name
  remote_virtual_network_id = module.hub_vnet.id
  allow_forwarded_traffic   = true
  use_remote_gateways       = false
}
```

## Troubleshooting

### Common Issues

**Issue**: Address space overlaps with existing network
- **Solution**: Use `az network vnet list` to check existing VNets and choose non-overlapping CIDR blocks.

**Issue**: Diagnostic settings fail to create
- **Solution**: Ensure proper permissions (Monitoring Contributor role), that the VNet resource is fully created, and that the Log Analytics workspace exists and is accessible.

**Issue**: Log Analytics workspace not found
- **Solution**: Verify the Log Analytics workspace exists in your subscription and the ID is correct. Use `az monitor log-analytics workspace show` to verify.

**Issue**: Insufficient permissions to create diagnostic settings
- **Solution**: Ensure you have the "Monitoring Contributor" or "Contributor" role on both the VNet and the Log Analytics workspace.

**Issue**: VNet creation succeeds but diagnostic settings fail
- **Solution**: Check that the Log Analytics workspace is in a supported region and that you have the correct workspace resource ID (not workspace ID GUID).

### Validation Commands

```powershell
# Check VNet configuration
az network vnet show --name <vnet-name> --resource-group <rg-name>

# List all VNets and their address spaces
az network vnet list --query "[].{Name:name, AddressSpace:addressSpace.addressPrefixes}" --output table

# Check Log Analytics workspace
az monitor log-analytics workspace show --workspace-name <workspace-name> --resource-group <rg-name>

# List diagnostic settings for VNet
az monitor diagnostic-settings list --resource <vnet-id>

# Test VNet connectivity
az network vnet check-ip-address --name <vnet-name> --resource-group <rg-name> --ip-address <ip>

# Query Log Analytics for VNet diagnostics (example KQL query)
# Run in Azure Portal > Log Analytics workspace > Logs
AzureDiagnostics 
| where ResourceType == "VIRTUALNETWORKS"
| where TimeGenerated > ago(24h)
| summarize count() by Category, bin(TimeGenerated, 1h)

# Check available IP addresses in address space
AzureMetrics
| where ResourceProvider == "MICROSOFT.NETWORK"
| where ResourceType == "VIRTUALNETWORKS"
| where MetricName == "IfUnderDDoSAttack" or MetricName == "BytesInDDoS"
| where TimeGenerated > ago(1h)
| summarize avg(Average) by bin(TimeGenerated, 5m), MetricName
```

## Cost Considerations

### Pricing Components

- **Virtual Network**: Free (no charge for VNet itself)
- **Log Analytics**: 
  - Data ingestion charges (~$2.30 per GB for first 5GB/day, then tiered pricing)
  - Data retention beyond 31 days (~$0.10 per GB/month)
  - First 5GB per billing account per day is free
- **Diagnostic Settings**: Free for configuration, but Log Analytics ingestion costs apply
- **Data Transfer**: Charges apply for data transfer between VNets, regions, or to internet

### Cost Optimization Tips

1. **Log Analytics**: Monitor data ingestion and consider filtering unnecessary logs
2. **Retention**: Adjust retention period based on compliance needs (31 days free for Log Analytics)
3. **Diagnostic Metrics**: Consider which metrics are truly necessary to reduce Log Analytics ingestion
4. **Data Sampling**: Consider sampling strategies for high-volume environments
5. **Log Analytics Workspace**: Use a shared workspace across multiple resources to maximize the free 5GB/day tier
6. **Capacity Reservation**: For consistent high-volume ingestion (>100GB/day), consider Log Analytics Capacity Reservation pricing

## Notes

- Virtual networks are free; you only pay for related services (VPN Gateway, Log Analytics ingestion, data transfer, etc.)
- Subnets should be created separately using the subnet module or additional resources
- VNet peering is configured outside this module
- Log Analytics workspace must exist before enabling diagnostic settings
- Diagnostic settings send VM Protection Alerts and AllMetrics to Log Analytics for querying and alerting
- Maximum of 1000 VNets per subscription per region (soft limit, can be increased)
- Log Analytics data ingestion is billable after the first 5GB/day free tier per billing account
- The `enable_flow_log` variable is reserved for future use; flow logs must be configured separately via NSG Flow Logs

## Module Maintenance

### Version History

- **v1.0.0** - Initial release
  - Virtual network creation with configurable address space
  - Optional diagnostic settings with Log Analytics integration
  - VM Protection Alerts monitoring
  - AllMetrics monitoring capability
  - Comprehensive tagging support
  - Standardized variable definitions

### Contributing

When contributing to this module:
1. Run `terraform fmt` to format code
2. Run `terraform validate` to check syntax
3. Test with both `enable_diagnostic` set to `true` and `false`
4. Verify Log Analytics workspace integration and data ingestion
5. Test KQL queries against diagnostic data to ensure proper data flow
6. Run security scans with Terrascan or tfsec
7. Update documentation for any new variables or outputs
8. Test in non-production environment first
9. Ensure backward compatibility with existing deployments

## References

- [Azure Virtual Network Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview)
- [VNet Planning and Design](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-vnet-plan-design-arm)
- [Azure Monitor Diagnostic Settings](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings)
- [Azure Log Analytics](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-overview)
- [KQL (Kusto Query Language)](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/)
- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [VNet Service Endpoints](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview)
- [Private Endpoints](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview)
- [Hub-Spoke Network Topology](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [Terraform AzureRM Provider - Virtual Network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)
- [Terraform AzureRM Provider - Diagnostic Settings](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting)
- [NSG Flow Logs (for separate implementation)](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-overview)
- [Azure Network Watcher](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-monitoring-overview)