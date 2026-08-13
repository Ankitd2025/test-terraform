# Azure Network Watcher Module

This Terraform module creates an Azure Network Watcher with NSG/VNet Flow Logs and Traffic Analytics integration for comprehensive network monitoring, diagnostics, and security analysis.

## Overview

Azure Network Watcher is a regional service that provides tools to monitor, diagnose, and analyze network traffic. This module deploys a Network Watcher instance and configures flow logs with Traffic Analytics integration to Log Analytics Workspace for deep network visibility and security monitoring.

## Features

- ✅ **Regional Network Watcher** - Automatic Network Watcher deployment per region
- ✅ **VNet Flow Logs** - Comprehensive network flow logging for virtual networks
- ✅ **Traffic Analytics** - Integration with Log Analytics for traffic analysis and insights
- ✅ **Flow Log Storage** - Configurable Storage Account for flow log retention
- ✅ **Automatic Retention** - 90-day retention policy for flow logs (hard-coded)
- ✅ **Workspace Integration** - Traffic Analytics powered by Log Analytics
- ✅ **Tagging Support** - Full tag management for governance
- ✅ **Network Diagnostics** - Enable diagnostic logging for network operations

## Prerequisites

- Azure subscription with appropriate permissions
- Terraform 1.0+
- Azure Provider 3.0+
- **Storage Account**: General-purpose v2 account for flow log storage (same region as Network Watcher)
- **Log Analytics Workspace**: For Traffic Analytics and diagnostics
- **Virtual Network**: Target resource for flow logging (existing)
- **Network Watcher Resource Group**: For Network Watcher deployment (typically "NetworkWatcherRG")

## Usage

### Basic Network Watcher with VNet Flow Logs

```hcl
module "network_watcher" {
  source = "./modules/network-watchers"

  virtual_network_name      = "vnet-app-prod-eastus-001"
  location                  = "eastus"
  resource_group_name       = "rg-app-prod-eastus"
  nw_resource_group_name    = "NetworkWatcherRG"
  
  # Flow Logs configuration
  enable_flow_log           = true
  virtual_network_id        = azurerm_virtual_network.app.id
  storage_account_id        = azurerm_storage_account.flowlogs.id
  workspace_id              = module.log_analytics.workspace_id
  workspace_region          = "eastus"
  workspace_resource_id     = module.log_analytics.id
  
  # Optional: Diagnostic logging
  enable_diagnostic         = false
  
  tags = {
    Environment = "production"
    Service     = "NetworkMonitoring"
    ManagedBy   = "Terraform"
  }
}
```

### Network Watcher with Diagnostics Enabled

```hcl
module "network_watcher_with_diagnostics" {
  source = "./modules/network-watchers"

  virtual_network_name      = "vnet-app-prod-eastus-001"
  location                  = "eastus"
  resource_group_name       = "rg-app-prod-eastus"
  nw_resource_group_name    = "NetworkWatcherRG"
  
  enable_flow_log           = true
  virtual_network_id        = azurerm_virtual_network.app.id
  storage_account_id        = azurerm_storage_account.flowlogs.id
  workspace_id              = module.log_analytics.workspace_id
  workspace_region          = "eastus"
  workspace_resource_id     = module.log_analytics.id
  
  # Enable diagnostic settings
  enable_diagnostic         = true
  
  tags = {
    Environment = "production"
    Service     = "NetworkMonitoring"
  }
}
```

### Multi-Region Network Watcher Setup

```hcl
locals {
  regions = {
    eastus = {
      location                = "eastus"
      nw_resource_group_name  = "NetworkWatcherRG-eastus"
      virtual_network_id      = azurerm_virtual_network.eastus.id
      virtual_network_name    = "vnet-app-prod-eastus-001"
    }
    westus = {
      location                = "westus"
      nw_resource_group_name  = "NetworkWatcherRG-westus"
      virtual_network_id      = azurerm_virtual_network.westus.id
      virtual_network_name    = "vnet-app-prod-westus-001"
    }
  }
}

module "network_watchers" {
  for_each = local.regions

  source = "./modules/network-watchers"

  virtual_network_name      = each.value.virtual_network_name
  location                  = each.value.location
  resource_group_name       = "rg-app-prod-${each.key}"
  nw_resource_group_name    = each.value.nw_resource_group_name
  
  enable_flow_log           = true
  virtual_network_id        = each.value.virtual_network_id
  storage_account_id        = azurerm_storage_account.flowlogs[each.key].id
  workspace_id              = module.log_analytics[each.key].workspace_id
  workspace_region          = each.key
  workspace_resource_id     = module.log_analytics[each.key].id
  
  enable_diagnostic         = true
  
  tags = {
    Environment = "production"
    Region      = each.key
    Service     = "NetworkMonitoring"
  }
}
```

### Complete Example with All Prerequisites

```hcl
locals {
  common_tags = {
    Environment = "production"
    Project     = "IncumbentFI"
    ManagedBy   = "Terraform"
  }
}

# Log Analytics Workspace for Traffic Analytics
module "log_analytics" {
  source = "./modules/log-analytics-workspaces"
  
  name                = "law-app-prod-eastus-001"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.app.name
  
  tags = local.common_tags
}

# Storage Account for Flow Logs
module "storage_account" {
  source = "./modules/storage-account"

  name                          = "stflowlogsprod001"
  resource_group_name           = azurerm_resource_group.app.name
  location                      = "eastus"
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  account_kind                  = "StorageV2"
  public_network_access_enabled = false
  https_traffic_only_enabled    = true
  min_tls_version               = "TLS1_2"
  shared_access_key_enabled     = true

  network_rules_default_action = "Allow"
  network_rules_bypass         = ["AzureServices"]
  
  tags = merge(local.common_tags, {
    Purpose = "FlowLogs"
  })
}

# Virtual Network
module "virtual_network" {
  source = "./modules/virtual-network"
  
  name                = "vnet-app-prod-eastus-001"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.app.name
  
  tags = local.common_tags
}

# Network Watcher with Flow Logs and Traffic Analytics
module "network_watcher" {
  source = "./modules/network-watchers"
  
  virtual_network_name      = module.virtual_network.name
  location                  = "eastus"
  resource_group_name       = azurerm_resource_group.app.name
  nw_resource_group_name    = "NetworkWatcherRG"
  
  enable_flow_log           = true
  virtual_network_id        = module.virtual_network.id
  storage_account_id        = module.storage_account.storage_account_id
  workspace_id              = module.log_analytics.workspace_id
  workspace_region          = module.log_analytics.location
  workspace_resource_id     = module.log_analytics.id
  
  enable_diagnostic         = true
  
  tags = merge(local.common_tags, {
    Service = "NetworkMonitoring"
  })
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `virtual_network_name` | Name of the virtual network | `string` | Yes | N/A |
| `location` | Azure region for the Network Watcher | `string` | Yes | N/A |
| `resource_group_name` | Resource group containing the virtual network | `string` | Yes | N/A |
| `nw_resource_group_name` | Resource group for the Network Watcher | `string` | Yes | N/A |
| `virtual_network_id` | ID of the virtual network for flow logs | `string` | Yes | N/A |
| `storage_account_id` | Storage Account ID for flow log storage | `string` | Yes | N/A |
| `workspace_id` | Log Analytics Workspace ID for Traffic Analytics | `string` | Yes | N/A |
| `workspace_region` | Log Analytics Workspace region | `string` | Yes | N/A |
| `workspace_resource_id` | Log Analytics Workspace resource ID | `string` | Yes | N/A |
| `enable_flow_log` | Enable flow logs for the virtual network | `bool` | No | `false` |
| `enable_diagnostic` | Enable diagnostic settings for Network Watcher | `bool` | No | `false` |
| `tags` | Tags to assign to resources | `map(string)` | Yes | N/A |

## Outputs

Currently, no outputs are defined. The module creates resources but does not export any values for reference by other modules.

## Flow Logs Details

### Naming Convention

- **Flow Log Name**: `flowlog-{virtual_network_name}`
- **Example**: If VNet is `vnet-app-prod-eastus-001`, flow log is `flowlog-vnet-app-prod-eastus-001`

### Storage Configuration

- **Retention Policy**: 90 days (hard-coded in flow-logs.tf)
- **Log Format**: JSON format
- **Storage Location**: Specified storage account (must be same region as Network Watcher)
- **Log Path**: `insights-logs-networksecuritygroupflowevent/resourceId=/{resource-id}/y={year}/m={month}/d={day}/h={hour}/m={minute}/`

### Traffic Analytics

- **Enabled**: Always enabled when flow logs are created
- **Log Analytics Integration**: Queries flow logs from storage account
- **Analysis Region**: Configured via `workspace_region` parameter
- **Workspace**: Log Analytics Workspace specified via `workspace_id` and `workspace_resource_id`
- **Processing**: Azure processes and analyzes traffic patterns in near real-time (10-60 minutes)

### Flow Log Information Captured

- **Source IP** and **Destination IP** tracking
- **Source Port** and **Destination Port** tracking
- **Layer 4 Protocol** (TCP, UDP, etc.)
- **Traffic Direction** (inbound/outbound)
- **Flow Status** (accepted/denied)
- **Bytes and Packets** transmitted
- **Timestamps** for each flow

## Best Practices

### Network Watcher Deployment

1. **Regional Placement** - Deploy one Network Watcher per region where you have resources
2. **Resource Group** - Use dedicated resource group (typically "NetworkWatcherRG")
3. **Consistent Naming** - Network Watcher name is auto-generated as `NetworkWatcher_{location}`
4. **Region Alignment** - Network Watcher must be in same region as monitored resources

### Flow Log Storage

1. **Separate Storage Account** - Dedicate storage for flow logs (don't mix with application data)
2. **Lifecycle Policies** - Archive logs after 90 days to cool/archive tier to reduce costs
3. **Access Control** - Restrict storage account access with network rules and RBAC
4. **Encryption** - Enable encryption with customer-managed keys if required for compliance
5. **Monitoring** - Alert on abnormal flow log volumes indicating potential issues

### Traffic Analytics

1. **Workspace Sizing** - Ensure Log Analytics has adequate capacity for data ingestion
2. **Retention Policy** - Set appropriate log retention (30-730 days) based on compliance needs
3. **Diagnostic Settings** - Enable diagnostics on Log Analytics workspace for troubleshooting
4. **Query Optimization** - Use KQL queries for efficient data analysis
5. **Cost Optimization** - Archive logs to reduce ingestion costs after initial analysis period

### Security & Monitoring

1. **Enable Flow Logs** - Always enable for production networks to detect threats
2. **Monitor Denied Traffic** - Alert on suspicious patterns of denied connections
3. **Regular Analysis** - Review traffic trends monthly for anomalies
4. **Threat Detection** - Integrate with Microsoft Defender for Network for advanced threats
5. **Compliance Logging** - Maintain audit trail of all network operations

## Troubleshooting

### Issue: "Network Watcher Does Not Exist"

**Possible Causes:**
- Network Watcher not created in the region
- Wrong resource group specified
- Resource deleted externally

**Solutions:**
```bash
# Check if Network Watcher exists
az network watcher list --query "[].{name:name, location:location}"

# Create/configure Network Watcher in specific region
az network watcher configure --location eastus --enabled true
```

### Issue: "Flow Logs Not Appearing in Storage"

**Possible Causes:**
- Storage account not accessible to Network Watcher service
- Flow logs not enabled in configuration
- Storage account in wrong region
- Storage account firewall blocking access

**Solutions:**
1. Verify storage account has "Microsoft.Network" service bypass enabled
2. Check storage account firewall allows Network Watcher service
3. Ensure storage account is in same region as Network Watcher
4. Wait 5-10 minutes for first logs to appear
5. Check flow-logs.tf to ensure flow logs are being created

### Issue: "Traffic Analytics Not Showing Data"

**Possible Causes:**
- Log Analytics workspace not configured properly
- Insufficient network traffic to analyze
- Workspace region mismatch with Network Watcher
- Traffic Analytics processing delay

**Solutions:**
```bash
# Verify workspace configuration
az monitor log-analytics workspace show \
  --resource-group myRG \
  --name myWorkspace

# Check workspace region
az monitor log-analytics workspace show \
  --resource-group myRG \
  --name myWorkspace \
  --query "location"

# Generate test traffic
ping -t destination-ip

# Query logs in Log Analytics
AzureNetworkAnalytics_CL
| where TimeGenerated > ago(1h)
| limit 100
```

### Issue: "Access Denied Writing to Storage Account"

**Possible Causes:**
- Network rules blocking access
- Insufficient permissions for Network Watcher service
- Storage account key rotated externally
- Service endpoint not configured

**Solutions:**
1. Add "Microsoft.Network" to storage account service bypass list
2. Verify Network Watcher service principal has access
3. Check storage account firewall rules (default should allow Network Watcher)
4. Verify storage account hasn't been locked with resource lock
5. Check diagnostic logs for detailed error messages

### Issue: "Flow Logs Storage Quota Exceeded"

**Possible Causes:**
- High network traffic volume (flows grow quickly)
- Long retention period accumulating data
- No lifecycle policy to archive old logs
- Insufficient storage account capacity

**Solutions:**
1. Implement lifecycle policies to archive logs to cool/archive tier
2. Reduce retention period in flow-logs.tf if not required for compliance
3. Use separate storage account for different VNets
4. Monitor storage account size regularly and set alerts
5. Scale up storage account SKU if needed

## Integration with Other Modules

### With Virtual Network

```hcl
module "virtual_network" {
  source = "./modules/virtual-network"
  # ... configuration
}

module "network_watcher" {
  source = "./modules/network-watchers"

  virtual_network_id   = module.virtual_network.id
  virtual_network_name = module.virtual_network.name
  # ... other configuration
}
```

### With Log Analytics Workspace

```hcl
module "log_analytics" {
  source = "./modules/log-analytics-workspaces"
  # ... configuration
}

module "network_watcher" {
  source = "./modules/network-watchers"

  workspace_id          = module.log_analytics.workspace_id
  workspace_region      = module.log_analytics.location
  workspace_resource_id = module.log_analytics.id
  # ... other configuration
}
```

### With Storage Account

```hcl
module "storage_account" {
  source = "./modules/storage-account"
  # ... configuration
}

module "network_watcher" {
  source = "./modules/network-watchers"

  storage_account_id = module.storage_account.storage_account_id
  # ... other configuration
}
```

## Related Modules

- [Virtual Network](../virtual-network/readme.md) - For network infrastructure
- [Log Analytics Workspaces](../log-analytics-workspaces/readme.md) - For Traffic Analytics
- [Storage Account](../storage-account/readme.md) - For flow log storage
- [Network Security Groups](../network-security-groups/readme.md) - For network security

## Additional Resources

- [Azure Network Watcher Documentation](https://learn.microsoft.com/en-us/azure/network-watcher/)
- [Flow Logs Overview](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-overview)
- [Traffic Analytics](https://learn.microsoft.com/en-us/azure/network-watcher/traffic-analytics)
- [Network Watcher Troubleshooting](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-troubleshoot-overview)
- [KQL Query Examples for Flow Logs](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-using-open-source-tools)

## Notes

- Network Watcher is created per region with naming pattern: `NetworkWatcher_{location}` (auto-generated)
- Flow logs are always enabled when the module is deployed (no conditional check in flow-logs.tf)
- Traffic Analytics processing may take 10-60 minutes to populate with initial data
- 90-day retention is hard-coded; modify `retention_policy.days` in flow-logs.tf if different retention is needed
- **Costs**: Network Watcher itself is free; charges apply for flow logs storage and Log Analytics data ingestion
- Flow logs consume approximately 1-5 GB per day depending on network traffic volume
- Traffic Analytics provides near real-time analysis of network patterns and threats
- Flow logs help with compliance (PCI-DSS, HIPAA) by providing audit trails of network access

## Security Best Practices

1. **Enable Flow Logs for Production**: Essential for security monitoring and compliance
2. **Use Dedicated Storage Account**: Isolate flow log data from application data
3. **Enable Traffic Analytics**: Provides actionable security insights
4. **Set Appropriate Retention**: Balance compliance needs with storage costs
5. **Monitor Storage Costs**: Flow logs can generate significant data volume
6. **Secure Storage Account**: Use private endpoints and restrict access
7. **Regular Review**: Set up alerts for suspicious traffic patterns
8. **Integrate with SIEM**: Feed flow logs to Azure Sentinel or third-party SIEM
9. **Use NetworkWatcherRG**: Follow Azure convention for resource group naming
10. **Tag Resources**: Maintain clear identification for billing and management

## Monitoring and Alerting

### Example Alert for Suspicious Traffic

```hcl
resource "azurerm_monitor_scheduled_query_rules_alert" "suspicious_traffic" {
  name                = "alert-suspicious-traffic"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  data_source_id = module.log_analytics.id
  description    = "Alert when malicious IPs are detected"
  enabled        = true
  
  query = <<-QUERY
    AzureNetworkAnalytics_CL
    | where SubType_s == "FlowLog" and MaliciousFlow_s == "Y"
    | summarize Count = count() by SrcIP_s
    | where Count > 5
  QUERY
  
  severity    = 2
  frequency   = 5
  time_window = 30
  
  action {
    action_group = [azurerm_monitor_action_group.security_team.id]
  }
  
  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }
}
```

## Troubleshooting

### Common Issues

**Issue**: Network Watcher already exists in region
- **Solution**: Import existing Network Watcher or delete and recreate
  ```bash
  # Import existing
  terraform import module.network_watcher.azurerm_network_watcher.azurerm_network_watcher \
    /subscriptions/{subscription-id}/resourceGroups/NetworkWatcherRG/providers/Microsoft.Network/networkWatchers/NetworkWatcher_eastus
  ```

**Issue**: Flow logs not appearing in storage account
- **Solution**: 
  1. Verify storage account is in same region as Network Watcher
  2. Check that Network Watcher has permissions to write to storage account
  3. Wait up to 60 minutes for first flow log entries
  4. Verify there is actual network traffic to log

**Issue**: Traffic Analytics not showing data
- **Solution**: 
  1. Ensure Log Analytics workspace is properly configured
  2. Verify workspace_id is the GUID, not the resource ID
  3. Check that flow logs are enabled and working
  4. Wait 60-90 minutes for initial processing
  5. Verify workspace has sufficient quota for data ingestion

**Issue**: Storage account costs are high
- **Solution**: 
  1. Review retention policy (default 90 days may be too long)
  2. Consider lifecycle management policies to move old data to cool/archive tier
  3. Evaluate if all VNets need flow logging
  4. Monitor data ingestion rates

**Issue**: Cannot create Network Watcher in NetworkWatcherRG
- **Solution**: 
  1. Ensure NetworkWatcherRG exists in the correct region
  2. Verify you have permissions to create resources in NetworkWatcherRG
  3. Check if Azure automatically created Network Watcher (may need to import)

**Issue**: Module references undefined resource
- **Solution**: This module has a known issue in flow-logs.tf referencing `azurerm_virtual_network.azurerm_virtual_network.name` which doesn't exist in the module. Use the `name` variable which is passed in.

### Validation Commands

```powershell
# List all Network Watchers
az network watcher list --output table

# Show Network Watcher details
az network watcher show --name NetworkWatcher_eastus --resource-group NetworkWatcherRG

# List flow logs
az network watcher flow-log list --location eastus --output table

# Show flow log configuration
az network watcher flow-log show \
  --location eastus \
  --name flowlog-vnet-incumbentfi-prod-eastus-001

# Test Network Watcher connectivity
az network watcher test-connectivity \
  --source-resource myVM \
  --dest-resource myOtherVM \
  --protocol TCP \
  --dest-port 443

# Check storage account for flow logs
az storage blob list \
  --account-name stflowlogsprod001 \
  --container-name insights-logs-networksecuritygroupflowevent \
  --output table

# Query Traffic Analytics
# (Run in Azure Portal > Log Analytics > Logs)
# AzureNetworkAnalytics_CL | take 10

# Terraform validation
terraform init
terraform validate
terraform plan
```

## Module Validation

### Pre-deployment Checklist

```powershell
# Create NetworkWatcherRG if it doesn't exist
az group create --name NetworkWatcherRG --location eastus

# Verify storage account exists and is in correct region
az storage account show --name stflowlogsprod001 --resource-group myRG

# Verify Log Analytics workspace exists
az monitor log-analytics workspace show --workspace-name law-prod-001 --resource-group myRG

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment
terraform plan

# Format code
terraform fmt -recursive
```

## Notes

- **Network Watcher is regional**: One Network Watcher per Azure region
- **Azure auto-creates Network Watchers**: Azure may automatically create Network Watcher when you create first VNet in a region
- **NetworkWatcherRG convention**: Use `NetworkWatcherRG` resource group for all Network Watchers following Azure's pattern
- **Flow logs naming**: Module automatically names flow logs as `flowlog-<vnet-name>`
- **90-day retention**: Default retention period balances compliance and storage costs
- **Storage account location**: Must be in same region as Network Watcher
- **Log Analytics location**: Can be in different region for Traffic Analytics
- **Initial delay**: First flow logs may take 60+ minutes to appear
- **Traffic Analytics processing**: Takes 60-90 minutes for initial data to appear
- **Storage account type**: Requires StorageV2 (general-purpose v2)
- **Module limitation**: Flow log resource references virtual network name that should be passed via variable
- **No outputs defined**: Consider adding outputs for Network Watcher ID and Flow Log ID

## Module Maintenance

### Version History

- **v1.0.0** - Initial release
  - Network Watcher creation with regional naming
  - NSG/VNet Flow Logs support
  - Traffic Analytics integration with Log Analytics
  - 90-day retention policy
  - Storage account integration
  - Comprehensive tagging support

### Contributing

When contributing to this module:
1. Run `terraform fmt` to format code
2. Run `terraform validate` to check syntax
3. Test with flow logs enabled and disabled
4. Verify Traffic Analytics integration
5. Test with different retention periods
6. Verify storage account integration
7. Test multi-region deployments
8. Fix the virtual network resource reference issue in flow-logs.tf
9. Add output definitions for created resources
10. Update documentation for any new variables or outputs
11. Test in non-production environment first

### Known Issues

- **flow-logs.tf**: References `azurerm_virtual_network.azurerm_virtual_network.name` which doesn't exist in module. Should use `var.name` instead.

## References

- [Azure Network Watcher Documentation](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-overview)
- [NSG Flow Logs](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-overview)
- [Traffic Analytics](https://learn.microsoft.com/en-us/azure/network-watcher/traffic-analytics)
- [Network Watcher Diagnostic Tools](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-monitoring-overview)
- [Flow Log Schema](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-overview#log-format)
- [Query Flow Logs](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-visualize-nsg-flow-logs-power-bi)
- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Network Watcher Pricing](https://azure.microsoft.com/en-us/pricing/details/network-watcher/)
- [Terraform AzureRM Provider - Network Watcher](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher)
- [Terraform AzureRM Provider - Flow Log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher_flow_log)