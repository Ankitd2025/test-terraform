# Azure Private Endpoint Module

This Terraform module creates and manages Azure Private Endpoints, enabling private connectivity to Azure PaaS services and custom resources without exposing them to the public internet.

## Overview

Private Endpoints provide a way to connect to Azure services using private IP addresses within your virtual network. This module simplifies the creation of private endpoints with integrated private DNS zone configuration for seamless private DNS resolution.

## Features

- ✅ **Private Endpoint Creation** - Secure private connectivity to Azure services
- ✅ **Automatic DNS Resolution** - Integrated private DNS zone group configuration
- ✅ **Private Service Connection** - Automatic connection setup to target resources
- ✅ **Multi-Subresource Support** - Support for multiple service subresources (e.g., blob, table, file for Storage)
- ✅ **Diagnostic Logging** - Optional monitoring and audit logging
- ✅ **Network Isolation** - Resources remain completely private without public exposure
- ✅ **Tag Management** - Consistent tagging for resource management

## Prerequisites

- Azure subscription with appropriate permissions
- Virtual Network with a subnet configured for private endpoints
- Target resource (Storage Account, Key Vault, SQL Database, etc.)
- Private DNS Zone(s) linked to the virtual network
- Log Analytics Workspace (if diagnostic logging is enabled)

## Usage

### Basic Private Endpoint - Storage Account

```hcl
module "private_endpoint_storage" {
  source = "./modules/private-endpoints"

  name                           = "pe-storage-prod-eastus-001"
  location                       = "eastus"
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.subnet_private_endpoints.id
  private_connection_resource_id = azurerm_storage_account.sa.id
  subresource_names              = ["blob"]
  private_dns_zone_ids           = [module.private_dns_zone_blob.id]
  
  enable_diagnostic              = false
  
  tags = local.common_tags
}
```

### Private Endpoint - Key Vault with Diagnostics

```hcl
module "private_endpoint_keyvault" {
  source = "./modules/private-endpoints"

  name                           = "pe-keyvault-prod-eastus-001"
  location                       = "eastus"
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.subnet_private_endpoints.id
  private_connection_resource_id = azurerm_key_vault.kv.id
  subresource_names              = ["vault"]
  private_dns_zone_ids           = [module.private_dns_zone_keyvault.id]
  
  enable_diagnostic              = true
  log_analytics_workspace_id     = module.log_analytics_workspace.id
  
  tags = merge(local.common_tags, {
    Service = "KeyVault"
  })
}
```

### Multiple Private Endpoints using for_each

```hcl
locals {
  private_endpoints = {
    storage = {
      resource_id  = azurerm_storage_account.sa.id
      subresources = ["blob", "file"]
      dns_zone_ids = [module.private_dns_zone_blob.id, module.private_dns_zone_file.id]
    }
    sql = {
      resource_id  = azurerm_mssql_server.sql.id
      subresources = ["sqlServer"]
      dns_zone_ids = [module.private_dns_zone_sql.id]
    }
    keyvault = {
      resource_id  = azurerm_key_vault.kv.id
      subresources = ["vault"]
      dns_zone_ids = [module.private_dns_zone_kv.id]
    }
  }
}

module "private_endpoints" {
  for_each = local.private_endpoints

  source = "./modules/private-endpoints"

  name                           = "pe-${each.key}-prod-eastus-001"
  location                       = "eastus"
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.subnet_private_endpoints.id
  private_connection_resource_id = each.value.resource_id
  subresource_names              = each.value.subresources
  private_dns_zone_ids           = each.value.dns_zone_ids
  
  enable_diagnostic              = true
  log_analytics_workspace_id     = module.log_analytics_workspace.id
  
  tags = merge(local.common_tags, {
    Service = title(each.key)
  })
  
  depends_on = [module.subnet_private_endpoints]
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `name` | The name of the Private Endpoint | `string` | Yes | N/A |
| `location` | Azure region where the Private Endpoint will be created | `string` | Yes | N/A |
| `resource_group_name` | Name of the resource group | `string` | Yes | N/A |
| `subnet_id` | The ID of the subnet where the private endpoint will be created | `string` | Yes | N/A |
| `private_connection_resource_id` | The ID of the resource to connect to (Storage, Key Vault, SQL, etc.) | `string` | Yes | N/A |
| `subresource_names` | Subresources of the target resource (e.g., ["blob"], ["vault"], ["sqlServer"]) | `list(string)` | Yes | N/A |
| `private_dns_zone_ids` | List of Private DNS Zone IDs to link with the endpoint | `list(string)` | Yes | N/A |
| `enable_diagnostic` | Enable diagnostic logging for the Private Endpoint | `bool` | Yes | N/A |
| `log_analytics_workspace_id` | Log Analytics Workspace ID for diagnostic logs (required if `enable_diagnostic = true`) | `string` | Conditional | N/A |
| `tags` | Tags to assign to the Private Endpoint | `map(string)` | Yes | N/A |

## Outputs

| Name | Description |
|------|-------------|
| `private_endpoint_id` | The ID of the Private Endpoint |
| `private_endpoint_name` | The name of the Private Endpoint |
| `private_endpoint_ip_addresses` | The private IP address(es) assigned to the endpoint |
| `private_endpoint_nic_id` | The network interface card associated with the endpoint |

## Supported Azure Services

### Common Services with Private Endpoints

| Service | Subresource | Private DNS Zone |
|---------|-------------|------------------|
| **Storage Account** | blob, file, queue, table | privatelink.blob.core.windows.net |
| **Key Vault** | vault | privatelink.vaultcore.azure.net |
| **SQL Database** | sqlServer | privatelink.database.windows.net |
| **SQL Managed Instance** | sqlMi | privatelink.database.windows.net |
| **CosmosDB** | sql, mongodb, cassandra, gremlin, table | privatelink.documents.azure.com |
| **Azure App Service** | sites | privatelink.azurewebsites.net |
| **Azure Container Registry** | registry | privatelink.azurecr.io |
| **Azure Service Bus** | namespace | privatelink.servicebus.windows.net |
| **Azure Event Hubs** | namespace | privatelink.eventhubs.windows.net |
| **Azure Blob Storage** | blob | privatelink.blob.core.windows.net |
| **Azure File Share** | file | privatelink.file.core.windows.net |
| **Azure Data Lake Storage** | dfs | privatelink.dfs.core.windows.net |

## Subresource Names Reference

### Storage Account Subresources
```hcl
subresource_names = ["blob"]      # Blob Storage
subresource_names = ["file"]      # File Share
subresource_names = ["queue"]     # Queue Storage
subresource_names = ["table"]     # Table Storage
subresource_names = ["dfs"]       # Data Lake Storage Gen2
subresource_names = ["web"]       # Web Static Content
```

### Database Subresources
```hcl
subresource_names = ["sqlServer"]    # SQL Database
subresource_names = ["sqlMi"]        # SQL Managed Instance
subresource_names = ["sql"]          # CosmosDB SQL API
subresource_names = ["mongodb"]      # CosmosDB MongoDB API
subresource_names = ["cassandra"]    # CosmosDB Cassandra API
```

### Other Services
```hcl
subresource_names = ["vault"]           # Key Vault
subresource_names = ["sites"]           # App Service
subresource_names = ["registry"]        # Container Registry
subresource_names = ["namespace"]       # Service Bus/Event Hubs
```

## Architecture Diagram

```
Internet
   │
   ├─ (Blocked - No Public Access)
   │
Virtual Network (10.0.0.0/16)
   │
   ├─ Workload Subnet (10.0.1.0/24)
   │   └─ VMs/Services
   │
   └─ Private Endpoints Subnet (10.0.4.0/24)
       │
       ├─ PE - Storage (10.0.4.10)
       │   └─ Links to: Private DNS Zone (blob.core.windows.net)
       │
       ├─ PE - Key Vault (10.0.4.11)
       │   └─ Links to: Private DNS Zone (vaultcore.azure.net)
       │
       └─ PE - SQL (10.0.4.12)
           └─ Links to: Private DNS Zone (database.windows.net)

Azure Services (Cloud)
   ├─ Storage Account
   ├─ Key Vault
   └─ SQL Database
```

## Best Practices

### Planning & Design
1. **Dedicated Subnet**: Use a dedicated subnet for private endpoints
2. **DNS Resolution**: Create and link appropriate private DNS zones to your virtual network
3. **Naming Convention**: Follow `pe-{service}-{environment}-{region}-{instance}` pattern
4. **Resource Grouping**: Place endpoints in the same resource group as related resources

### Network Configuration
1. **Network Policies**: Set `private_endpoint_network_policies = "Disabled"` on the private endpoints subnet
2. **Route Tables**: Configure UDRs if needed for traffic routing
3. **NSG Rules**: Create NSG rules to allow traffic from workload subnets to endpoints
4. **Subnet Size**: Ensure subnet has sufficient IP addresses for all endpoints

### Security
1. **Isolation**: Ensure endpoints are not accessible from the public internet
2. **Access Control**: Use RBAC on target resources to restrict access
3. **Network Isolation**: Use NSGs and private endpoints together for defense in depth
4. **Firewall Rules**: Configure firewall rules on target resources to only allow private endpoint connections

### Monitoring & Maintenance
1. **Enable Diagnostics**: Enable diagnostic logging for security and troubleshooting
2. **Query Logs**: Use Log Analytics to monitor private endpoint connections
3. **Alerts**: Set up alerts for connection failures or suspicious activity
4. **Regular Review**: Periodically review and validate private endpoint configurations

### Cost Optimization
1. **Consolidation**: Use multiple subresources (e.g., blob+file) to reduce number of endpoints
2. **Selective Deployment**: Only create endpoints for services that require private connectivity
3. **DNS Zones**: Share private DNS zones across multiple endpoints

## Diagnostic Logging

### When Diagnostics Are Enabled

Diagnostic settings capture audit information and connection logs:
- **Connection Events**: Success/failure of private endpoint connections
- **DNS Resolution**: Private DNS queries and resolutions
- **Performance Metrics**: Latency and throughput data
- **Security Events**: Blocked connections and policy violations

### Example: Querying Private Endpoint Logs

```kusto
// Find connection failures
AzureDiagnostics
| where ResourceType == "PRIVATEENDPOINTS"
| where Status == "Failed"
| summarize Count = count() by SourceIP, DestinationPort, Status
| sort by Count desc

// Monitor private endpoint activity
AzureDiagnostics
| where ResourceType == "PRIVATEENDPOINTS"
| extend TimeGenerated, OperationName, ResultType
| summarize TotalEvents = count() by bin(TimeGenerated, 1h), OperationName
```

## Common Issues & Troubleshooting

### Issue: Cannot access resource through private endpoint

**Possible Causes:**
- Subnet doesn't have network policies disabled for private endpoints
- Private DNS zone not linked to virtual network
- NSG rules blocking traffic
- Firewall rules on target resource not allowing private endpoint

**Solutions:**
```hcl
# Ensure private endpoint network policies are disabled
resource "azurerm_subnet" "private_endpoints" {
  ...
  private_endpoint_network_policies = "Disabled"
}

# Verify DNS zone linking
resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "link-vnet"
  private_dns_zone_id   = azurerm_private_dns_zone.pdz.id
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

# Update firewall rules on target resource
resource "azurerm_storage_account_network_rules" "example" {
  ...
  default_action = "Deny"
  # Allow private endpoint connections
}
```

### Issue: DNS resolution not working

**Check:**
1. Verify private DNS zone is linked to VNet
2. Confirm DNS zone contains correct A records
3. Test DNS resolution from VM in the VNet

```powershell
# Test from Azure VM
nslookup mykeyvault.vaultcore.azure.net
# Should resolve to private IP (10.x.x.x)
```

### Issue: "Cannot find the private connection resource"

**Solution:**
- Verify `private_connection_resource_id` is correct
- Ensure the resource exists and is accessible
- Check RBAC permissions on the target resource

### Issue: Private endpoint stuck in "Pending" state

**Solution:**
- Check if resource is available and not being modified
- Verify the private service connection isn't already in use
- Check Azure activity logs for detailed error messages

## Naming Conventions

### Recommended Pattern

```
pe-{service}-{environment}-{region}-{instance}
```

### Examples

| Service | Name | Private DNS Zone |
|---------|------|------------------|
| Storage Blob | `pe-stgblob-prod-eastus-001` | privatelink.blob.core.windows.net |
| Key Vault | `pe-keyvault-prod-eastus-001` | privatelink.vaultcore.azure.net |
| SQL Database | `pe-sqldb-prod-eastus-001` | privatelink.database.windows.net |
| Container Registry | `pe-acr-prod-eastus-001` | privatelink.azurecr.io |
| App Service | `pe-appservice-prod-eastus-001` | privatelink.azurewebsites.net |

## Related Modules

- [Subnet](../subnet/readme.md) - For creating the private endpoints subnet
- [Private DNS Zone](../private-dns-zone/readme.md) - For DNS resolution
- [Virtual Network](../virtual-network/readme.md) - For network infrastructure
- [Key Vault](../key-vault/readme.md) - Common target for private endpoints
- [Log Analytics Workspaces](../log-analytics-workspaces/readme.md) - For diagnostic logging

## Additional Resources

- [Azure Private Endpoint Documentation](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview)
- [Private Link Service Subresources](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource)
- [Azure Private Link DNS Configuration](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns)
- [Azure Security Best Practices](https://learn.microsoft.com/en-us/azure/security/fundamentals/best-practices-and-patterns)
