# Azure Storage Account Module

This Terraform module creates and manages Azure Storage Accounts with advanced security configurations, network isolation, and compliance controls. It supports secure data storage with HTTPS enforcement, private access, and network-level access restrictions.

## Overview

Azure Storage Accounts provide cloud-based data storage for unstructured data (blobs), file shares, queues, and tables. This module simplifies creation of enterprise-grade storage accounts with built-in security best practices, network isolation, and management capabilities.

## Features

- ✅ **Multiple Storage Account Kinds** - StorageV2, BlobStorage, FileStorage, BlockBlobStorage
- ✅ **Flexible Replication Strategies** - LRS, GRS, RA-GRS, ZRS for different durability/availability needs
- ✅ **Network Isolation** - Private access with network rules and virtual network integration
- ✅ **HTTPS Enforcement** - TLS version control and encrypted-only traffic
- ✅ **Managed Identity** - System-assigned identity for authentication without keys
- ✅ **Public Access Control** - Granular control over public access and nested items
- ✅ **Shared Access Keys** - Optional SAK authentication for backward compatibility
- ✅ **Blob Versioning** - Enable version history for blob recovery and audit trails
- ✅ **Data Retention Policies** - Automatic retention for deleted blobs and containers with configurable days
- ✅ **Service Bypass** - Allows specific Azure services to bypass network restrictions
- ✅ **Enterprise-Ready Tagging** - Full tag support for cost allocation and governance

## Prerequisites

- Azure subscription with appropriate permissions
- Terraform 1.0+
- Azure Provider 3.0+
- Existing resource group
- For network isolation: existing virtual network and subnets

## Usage

### Basic Storage Account Creation

```hcl
module "storage_account" {
  source = "./modules/storage-account"

  name                          = "stmyappeastus001"
  resource_group_name           = "rg-myapp-prod-eastus"
  location                      = "eastus"
  account_tier                  = "Standard"
  account_replication_type      = "GRS"
  account_kind                  = "StorageV2"
  public_network_access_enabled = false
  https_traffic_only_enabled    = true
  min_tls_version               = "TLS1_2"
  shared_access_key_enabled     = true
  allow_nested_items_to_be_public = false

  versioning_enabled                  = false
  delete_retention_policy_days         = 0
  container_delete_retention_policy_days = 0

  network_rules_default_action             = "Allow"
  network_rules_bypass                     = ["AzureServices"]
  network_rules_virtual_network_subnet_ids = []

  tags = {
    Environment = "production"
    Workload    = "myapp"
  }
}
```

### Fully Isolated Storage Account (Network Restricted)

```hcl
module "storage_account_isolated" {
  source = "./modules/storage-account"

  name                          = "stmyappdata001"
  resource_group_name           = "rg-myapp-prod-eastus"
  location                      = "eastus"
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  account_kind                  = "StorageV2"
  public_network_access_enabled = false
  https_traffic_only_enabled    = true
  min_tls_version               = "TLS1_2"
  shared_access_key_enabled     = false  # Disable shared keys for security

  versioning_enabled                      = false
  delete_retention_policy_days            = 0
  container_delete_retention_policy_days  = 0

  network_rules_default_action = "Deny"
  network_rules_bypass         = ["AzureServices"]
  network_rules_virtual_network_subnet_ids = [
    azurerm_subnet.app.id,
    azurerm_subnet.integration.id
  ]

  tags = {
    Environment = "production"
    DataClass   = "confidential"
  }
}
```

### Storage Account with Blob Versioning and Retention

```hcl
module "premium_blob_storage" {
  source = "./modules/storage-account"

  name                          = "stpremiumblob001"
  resource_group_name           = "rg-myapp-prod-eastus"
  location                      = "eastus"
  account_tier                  = "Premium"
  account_replication_type      = "LRS"
  account_kind                  = "BlockBlobStorage"
  public_network_access_enabled = false
  https_traffic_only_enabled    = true
  min_tls_version               = "TLS1_2"
  shared_access_key_enabled     = false

  # Enable blob versioning for data recovery
  versioning_enabled                      = true
  delete_retention_policy_days            = 30      # Retain deleted blobs for 30 days
  container_delete_retention_policy_days  = 7       # Retain deleted containers for 7 days

  network_rules_default_action             = "Deny"
  network_rules_bypass                     = ["AzureServices"]
  network_rules_virtual_network_subnet_ids = [azurerm_subnet.app.id]

  tags = {
    Environment = "production"
    Purpose     = "premium-blob-storage"
  }
}
```

### Multi-Environment Storage Accounts with for_each

```hcl
locals {
  storage_accounts = {
    dev = {
      name                     = "stdeveastus001"
      tier                     = "Standard"
      replication              = "LRS"
      kind                     = "StorageV2"
      public_access            = false
      network_default_action   = "Allow"
      allow_nested_public      = false
      versioning               = false
      blob_retention           = 0
      container_retention      = 0
    }
    test = {
      name                     = "sttesteastus001"
      tier                     = "Standard"
      replication              = "GRS"
      kind                     = "StorageV2"
      public_access            = false
      network_default_action   = "Deny"
      allow_nested_public      = false
      versioning               = true
      blob_retention           = 7
      container_retention      = 7
    }
    prod = {
      name                     = "stprodeastus001"
      tier                     = "Standard"
      replication              = "GRS"
      kind                     = "StorageV2"
      public_access            = false
      network_default_action   = "Deny"
      allow_nested_public      = false
      versioning               = true
      blob_retention           = 30
      container_retention      = 7
    }
  }
}

module "multi_env_storage" {
  for_each = local.storage_accounts

  source = "./modules/storage-account"

  name                             = each.value.name
  resource_group_name              = "rg-myapp-${each.key}-eastus"
  location                         = "eastus"
  account_tier                     = each.value.tier
  account_replication_type         = each.value.replication
  account_kind                     = each.value.kind
  public_network_access_enabled    = each.value.public_access
  https_traffic_only_enabled       = true
  min_tls_version                  = "TLS1_2"
  shared_access_key_enabled        = each.key != "prod" ? true : false
  allow_nested_items_to_be_public  = each.value.allow_nested_public

  versioning_enabled                      = each.value.versioning
  delete_retention_policy_days            = each.value.blob_retention
  container_delete_retention_policy_days  = each.value.container_retention

  network_rules_default_action             = each.value.network_default_action
  network_rules_bypass                     = ["AzureServices"]
  network_rules_virtual_network_subnet_ids = each.key == "prod" ? [azurerm_subnet.app.id] : []

  tags = {
    Environment = each.key
    Workload    = "myapp"
  }
}
```

### Storage Account with Private Endpoints

```hcl
module "storage_account_secure" {
  source = "./modules/storage-account"

  name                          = "stsecuredata001"
  resource_group_name           = "rg-myapp-prod-eastus"
  location                      = "eastus"
  account_tier                  = "Standard"
  account_replication_type      = "GRS"
  account_kind                  = "StorageV2"
  public_network_access_enabled = false
  https_traffic_only_enabled    = true
  min_tls_version               = "TLS1_2"
  shared_access_key_enabled     = false

  versioning_enabled                      = true
  delete_retention_policy_days            = 30
  container_delete_retention_policy_days  = 7

  network_rules_default_action             = "Deny"
  network_rules_bypass                     = []  # No bypass, use private endpoints only
  network_rules_virtual_network_subnet_ids = []

  tags = {
    Environment = "production"
    Purpose     = "secure-data-storage"
  }
}

# Private endpoint for blob storage
module "blob_private_endpoint" {
  source = "./modules/private-endpoints"

  name                           = "pe-stblob-001"
  resource_group_name            = azurerm_resource_group.rg.name
  location                       = azurerm_resource_group.rg.location
  subnet_id                      = azurerm_subnet.app.id
  private_dns_zone_ids           = [azurerm_private_dns_zone.storage.id]
  target_resource_id             = module.storage_account_secure.storage_account_id
  subresource_names              = ["blob"]

  tags = {
    Environment = "production"
  }
}

# Private endpoint for file storage
module "file_private_endpoint" {
  source = "./modules/private-endpoints"

  name                           = "pe-stfile-001"
  resource_group_name            = azurerm_resource_group.rg.name
  location                       = azurerm_resource_group.rg.location
  subnet_id                      = azurerm_subnet.app.id
  private_dns_zone_ids           = [azurerm_private_dns_zone.storage.id]
  target_resource_id             = module.storage_account_secure.storage_account_id
  subresource_names              = ["file"]

  tags = {
    Environment = "production"
  }
}
```

### Storage Account with Managed Identity Access

```hcl
# Create user-assigned managed identity
resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "app-identity-001"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Create storage account
module "storage_account" {
  source = "./modules/storage-account"

  name                          = "stmanagedid001"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  account_tier                  = "Standard"
  account_replication_type      = "GRS"
  account_kind                  = "StorageV2"
  public_network_access_enabled = false
  https_traffic_only_enabled    = true
  min_tls_version               = "TLS1_2"
  shared_access_key_enabled     = false

  versioning_enabled                      = true
  delete_retention_policy_days            = 30
  container_delete_retention_policy_days  = 7

  network_rules_default_action             = "Deny"
  network_rules_bypass                     = ["AzureServices"]
  network_rules_virtual_network_subnet_ids = [azurerm_subnet.app.id]

  tags = {
    Environment = "production"
  }
}

# Grant storage account access to managed identity
module "rbac_blob_access" {
  source = "./modules/rbac"

  scope                = module.storage_account.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.app_identity.principal_id
}

# Grant storage account access for Azure services
module "rbac_service_access" {
  source = "./modules/rbac"

  scope                = module.storage_account.storage_account_id
  role_definition_name = "Storage Account Key Operator Service Role"
  principal_id         = data.azurerm_client_config.current.object_id
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `name` | Name of the storage account (must be 3-24 lowercase alphanumeric characters) | `string` | Yes | N/A |
| `resource_group_name` | Name of the resource group | `string` | Yes | N/A |
| `location` | Azure region for the storage account | `string` | Yes | N/A |
| `account_tier` | Performance tier - `Standard` or `Premium` | `string` | Yes | N/A |
| `account_replication_type` | Replication strategy - `LRS`, `GRS`, `RA-GRS`, or `ZRS` | `string` | Yes | N/A |
| `account_kind` | Kind of storage account - `StorageV2`, `BlobStorage`, `FileStorage`, `BlockBlobStorage` | `string` | Yes | N/A |
| `public_network_access_enabled` | Allow public network access | `bool` | Yes | N/A |
| `https_traffic_only_enabled` | Enforce HTTPS-only traffic | `bool` | Yes | N/A |
| `min_tls_version` | Minimum TLS version - `TLS1_0`, `TLS1_1`, or `TLS1_2` | `string` | Yes | N/A |
| `allow_nested_items_to_be_public` | Allow blobs/files to be public | `bool` | Yes | N/A |
| `shared_access_key_enabled` | Enable shared access key authentication | `bool` | Yes | N/A |
| `network_rules_bypass` | Azure services to bypass network rules | `list(string)` | Yes | N/A |
| `network_rules_default_action` | Default network action - `Allow` or `Deny` | `string` | Yes | N/A |
| `network_rules_virtual_network_subnet_ids` | Allowed subnet IDs when default action is `Deny` | `list(string)` | No | `null` |
| `versioning_enabled` | Enable blob versioning for version history and recovery | `bool` | Yes | N/A |
| `delete_retention_policy_days` | Days to retain deleted blobs (0 to disable) | `number` | Yes | N/A |
| `container_delete_retention_policy_days` | Days to retain deleted containers (0 to disable) | `number` | Yes | N/A |
| `tags` | Tags to assign to storage account | `map(string)` | Yes | N/A |

## Outputs

| Name | Description | Type |
|------|-------------|------|
| `storage_account_id` | The ID of the storage account | `string` |
| `storage_account_name` | The name of the storage account | `string` |
| `storage_account_identity` | The managed identity (system-assigned) of the storage account | `object` |

## Account Tiers

| Tier | Use Case | Performance | Cost |
|------|----------|-------------|------|
| **Standard** | General-purpose workloads (blobs, files, queues, tables) | Standard throughput | Lower cost |
| **Premium** | High-performance workloads requiring consistent latency | High throughput/IOPS | Higher cost |

## Replication Strategies

| Strategy | Redundancy | Availability | Use Case |
|----------|-----------|--------------|----------|
| **LRS** (Locally Redundant Storage) | Single region, 3 copies | 99.9% | Dev/test, non-critical data |
| **GRS** (Geo-Redundant Storage) | Two regions, 3 copies each | 99.9% | Critical business data |
| **RA-GRS** (Read-Access GRS) | GRS + read from secondary | 99.99% | Disaster recovery with read access |
| **ZRS** (Zone-Redundant Storage) | Multiple availability zones | 99.99% | High-availability within region |

## Storage Account Kinds

| Kind | Capabilities | Use Case |
|------|--------------|----------|
| **StorageV2** | Blobs, Files, Queues, Tables | General-purpose, most workloads |
| **BlobStorage** | Blobs only | Blob-specific workloads |
| **FileStorage** | File shares only | Azure Files workloads |
| **BlockBlobStorage** | Block blobs only | Premium blob storage |

## Network Security

### Allow Mode (Public + Network Rules)

```hcl
network_rules_default_action = "Allow"
network_rules_bypass         = ["AzureServices"]
```

- Allows all public access by default
- Specific subnets can be restricted
- Azure services bypass restrictions

### Deny Mode (Private + Approved Access)

```hcl
network_rules_default_action = "Deny"
network_rules_bypass         = ["AzureServices"]
network_rules_virtual_network_subnet_ids = [
  azurerm_subnet.app.id
]
```

- Denies all access by default
- Only specified subnets allowed
- Private endpoints recommended
- Azure services can bypass if configured

## Best Practices

### Security & Access Control

1. **Disable Public Access** - Set `public_network_access_enabled = false` for non-public workloads
2. **Enforce HTTPS** - Always set `https_traffic_only_enabled = true`
3. **Require TLS 1.2** - Set `min_tls_version = "TLS1_2"`
4. **Use Managed Identity** - Disable SAKs with `shared_access_key_enabled = false`
5. **Network Isolation** - Use private endpoints instead of public endpoints
6. **Subnet Whitelisting** - When needed, restrict to specific subnets
7. **Disable Public Blob Access** - Set `allow_nested_items_to_be_public = false`

### Replication Strategy

1. **Development/Testing** - Use `LRS` to minimize costs
2. **Production Critical** - Use `GRS` or `RA-GRS` for geographic redundancy
3. **High Availability** - Use `ZRS` for multi-zone protection
4. **Read Access Needed** - Use `RA-GRS` for read-only disaster recovery

### Naming Conventions

Follow Azure naming guidelines:
- Length: 3-24 characters
- Characters: Lowercase letters and digits only
- Globally unique across Azure
- Pattern: `st{workload}{environment}{region}{instance}`
- Example: `stmyappproductioneastus001`

### Data Retention & Recovery

1. **Blob Versioning** - Enable `versioning_enabled = true` to maintain version history for all blobs
2. **Soft Delete for Blobs** - Set `delete_retention_policy_days` to retain deleted blobs (1-365 days)
   - Prevents accidental permanent deletion
   - Allows recovery within retention window
   - Recommend 30 days for production
3. **Soft Delete for Containers** - Set `container_delete_retention_policy_days` to protect containers (1-365 days)
   - Protect against accidental container deletion
   - Recommend 7 days minimum
4. **Retention Policies** - Use blob lifecycle policies to automatically archive/delete aged data

**Recommended Production Settings:**
```hcl
versioning_enabled                      = true
delete_retention_policy_days            = 30
container_delete_retention_policy_days  = 7
```

### Monitoring & Auditing

1. **Enable Diagnostics** - Log all access and operations
2. **Azure Monitor** - Set up alerts for anomalies
3. **Access Reviews** - Regularly review who has access
4. **Activity Logs** - Audit storage account modifications

## Troubleshooting

### Issue: "Storage Account Name Not Available"

**Possible Causes:**
- Name not globally unique
- Invalid characters (uppercase, special chars)
- Name too short (<3) or too long (>24)

**Solutions:**
```bash
# Check availability
az storage account check-name --name mystorageaccount

# Generate unique name
$uniqueName = "st" + (Get-Random).ToString() + "data"
```

### Issue: "Authentication Failed" / "403 Forbidden"

**Possible Causes:**
- Insufficient role assignment
- Network rules blocking access
- Shared access key disabled
- Expired SAS token

**Solutions:**
1. Check role assignments via RBAC module
2. Verify network rules allow your IP/subnet
3. Enable SAK if temporarily needed for testing
4. Check SAS token expiration date

### Issue: "The Specified Resource Does Not Exist"

**Possible Causes:**
- Storage account doesn't exist
- Wrong storage account name
- Wrong region/subscription

**Solutions:**
```bash
# List storage accounts
az storage account list --query "[].name"

# Get storage account details
az storage account show --name mystorageaccount --resource-group myresourcegroup
```

### Issue: Private Endpoint Connection Fails

**Possible Causes:**
- Network rules blocking private endpoint subnet
- DNS not resolving private IP
- Private endpoint not properly linked to DNS zone

**Solutions:**
1. Verify subnet is in `network_rules_virtual_network_subnet_ids`
2. Check private DNS zone links to VNet
3. Verify private endpoint network interface has correct DNS
4. Test DNS resolution: `nslookup mystorageaccount.blob.core.windows.net`

### Issue: "Storage Account Is Locked"

**Possible Causes:**
- Resource group has delete lock
- Storage account has resource lock
- Subscription-level policies

**Solutions:**
```bash
# List locks on resource group
az lock list --resource-group myresourcegroup

# Remove lock if needed
az lock delete --ids {lock-id}
```

## Integration with Other Modules

### With Private Endpoints

```hcl
module "storage_account" {
  source = "./modules/storage-account"
  # ... configuration
}

module "blob_private_endpoint" {
  source = "./modules/private-endpoints"
  
  target_resource_id = module.storage_account.storage_account_id
  subresource_names  = ["blob"]
  # ... additional configuration
}
```

### With RBAC for Access Control

```hcl
module "storage_account" {
  source = "./modules/storage-account"
  # ... configuration
}

module "blob_contributor_access" {
  source = "./modules/rbac"
  
  scope                = module.storage_account.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}
```

### With Key Vault for Connection Strings

```hcl
module "storage_account" {
  source = "./modules/storage-account"
  # ... configuration
}

# Store connection string in Key Vault
module "key_vault_secret" {
  source = "./modules/key-vault-secret"
  
  name         = "storage-connection-string"
  value        = "DefaultEndpointsProtocol=https;AccountName=${module.storage_account.storage_account_name};..."
  key_vault_id = module.key_vault.key_vault_id
}
```

## Related Modules

- [Private Endpoints](../private-endpoints/readme.md) - For private connectivity
- [RBAC](../rbac/readme.md) - For access control
- [Key Vault](../key-vault/readme.md) - For secure credential storage
- [Resource Group](../resource-group/readme.md) - For resource organization
- [Network Watchers](../network-watchers/readme.md) - For monitoring network access

## Additional Resources

- [Azure Storage Security Best Practices](https://learn.microsoft.com/en-us/azure/storage/common/security-best-practices)
- [Azure Storage Account Overview](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview)
- [Storage Account Types and Features](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-types)
- [Azure Storage Redundancy Options](https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy)
- [Private Endpoints for Azure Storage](https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints)
- [Azure Storage Firewall and Virtual Networks](https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security)

## Notes

- Storage account names must be globally unique across all Azure subscriptions
- Changing account tier may require downtime
- GRS/RA-GRS replication may incur additional costs
- Network rules take precedence over service endpoints
- Private endpoints are recommended for production workloads
- Managed identity is always created (system-assigned)
- Shared access keys provide full account access when enabled
- Data retention policies are separate from network rules
