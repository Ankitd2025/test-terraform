# Azure Key Vault Customer-Managed Keys (CMK) Module

This Terraform module creates and manages Customer-Managed Keys (CMK) in Azure Key Vault with automatic key rotation policies for secure encryption of Azure services and data.

## Overview

Customer-Managed Keys allow you to maintain control over encryption keys used to protect your data in Azure services. This module simplifies the creation of encryption keys in Key Vault with built-in rotation policies for enhanced security and compliance.

## Features

- ✅ **Key Creation** - Create RSA and EC keys in Azure Key Vault
- ✅ **Flexible Key Types** - Support for RSA and Elliptic Curve (EC) keys
- ✅ **Configurable Key Size** - Adjust key sizes based on security requirements (2048, 3072, 4096 for RSA)
- ✅ **Key Operations** - Define allowed operations (encrypt, decrypt, sign, verify, wrapKey, unwrapKey, etc.)
- ✅ **Automatic Rotation** - Built-in automatic key rotation policies
- ✅ **Rotation Scheduling** - Configure rotation trigger time before key expiry
- ✅ **Tag Management** - Apply consistent tagging for governance
- ✅ **Compliance Ready** - Meet encryption and key management compliance requirements

## Prerequisites

- Azure subscription with appropriate permissions
- Existing Azure Key Vault (Premium SKU recommended for CMK operations)
- Key Vault must have RBAC authorization enabled
- Appropriate RBAC roles assigned for key creation
- Log Analytics Workspace (if diagnostic logging is enabled on Key Vault)

## Usage

### Basic - RSA Customer-Managed Key

```hcl
module "cmk_key" {
  source = "./modules/key-vault-cmk"

  name                   = "key-cmk-prod-eastus-001"
  key_vault_id           = module.key_vault.key_vault_id
  key_type               = "RSA"
  key_size               = 4096
  key_opts               = ["encrypt", "decrypt", "wrapKey", "unwrapKey", "sign", "verify"]
  time_before_expiry     = "P30D"
  notify_before_expiry   = "P7D"
  expire_after           = "P365D"

  tags = local.common_tags
}
```

### Elliptic Curve (EC) Key with Smaller Rotation Window

```hcl
module "cmk_ec_key" {
  source = "./modules/key-vault-cmk"

  name                   = "key-cmk-ec-prod-eastus-001"
  key_vault_id           = module.key_vault.key_vault_id
  key_type               = "EC"
  key_size               = 256  # Not used for EC, but required parameter
  key_opts               = ["sign", "verify"]
  time_before_expiry     = "P90D"
  notify_before_expiry   = "P14D"
  expire_after           = "P730D"

  tags = merge(local.common_tags, {
    KeyType = "EC"
  })
}
```

### Multiple CMK Keys for Different Services

```hcl
locals {
  cmk_keys = {
    storage = {
      key_type           = "RSA"
      key_size           = 4096
      operations         = ["encrypt", "decrypt", "wrapKey", "unwrapKey"]
      rotation           = "P30D"
      notify_before      = "P7D"
      expire_after       = "P365D"
    }
    database = {
      key_type           = "RSA"
      key_size           = 3072
      operations         = ["wrapKey", "unwrapKey"]
      rotation           = "P60D"
      notify_before      = "P14D"
      expire_after       = "P730D"
    }
    backup = {
      key_type           = "RSA"
      key_size           = 2048
      operations         = ["encrypt", "decrypt"]
      rotation           = "P90D"
      notify_before      = "P21D"
      expire_after       = "P1095D"
    }
  }
}

module "cmk_keys" {
  for_each = local.cmk_keys

  source = "./modules/key-vault-cmk"

  name                   = "key-${each.key}-prod-eastus-001"
  key_vault_id           = module.key_vault.key_vault_id
  key_type               = each.value.key_type
  key_size               = each.value.key_size
  key_opts               = each.value.operations
  time_before_expiry     = each.value.rotation
  notify_before_expiry   = each.value.notify_before
  expire_after           = each.value.expire_after

  tags = merge(local.common_tags, {
    Service = title(each.key)
  })
}
```

### CMK with Storage Account Encryption

```hcl
# Create Key Vault with CMK key
module "key_vault" {
  source = "./modules/key-vault"

  name                       = "kv-cmk-prod-eastus-001"
  location                   = "eastus"
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"  # Premium tier recommended for CMK
  public_network_access_enabled = false
  rbac_authorization_enabled = true

  tags = local.common_tags
}

# Create Customer-Managed Key
module "storage_cmk" {
  source = "./modules/key-vault-cmk"

  name                   = "key-storage-cmk-prod-eastus-001"
  key_vault_id           = module.key_vault.key_vault_id
  key_type               = "RSA"
  key_size               = 4096
  key_opts               = ["encrypt", "decrypt", "wrapKey", "unwrapKey"]
  time_before_expiry     = "P30D"
  notify_before_expiry   = "P7D"
  expire_after           = "P365D"

  tags = local.common_tags

  depends_on = [module.key_vault]
}

# Use CMK for Storage Account encryption
resource "azurerm_storage_account" "sa" {
  name                     = "stgcmkprod001"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  customer_managed_key {
    key_vault_key_id = module.storage_cmk.key_vault_cmk_key_id
  }

  tags = local.common_tags

  depends_on = [module.storage_cmk]
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `name` | The name of the Customer-Managed Key | `string` | Yes | N/A |
| `key_vault_id` | The resource ID of the Azure Key Vault | `string` | Yes | N/A |
| `key_type` | The type of the key (RSA or EC) | `string` | Yes | N/A |
| `key_size` | The size of the key in bits (2048, 3072, 4096 for RSA; 256, 384, 521 for EC) | `number` | Yes | N/A |
| `key_opts` | List of allowed key operations | `list(string)` | Yes | N/A |
| `time_before_expiry` | Time before key expiry to trigger automatic rotation (e.g., P30D for 30 days) | `string` | Yes | N/A |
| `notify_before_expiry` | Time before key expiry to send notification (e.g., P7D for 7 days) | `string` | Yes | N/A |
| `expire_after` | Duration after which the key will expire (e.g., P365D for 365 days) | `string` | Yes | N/A |
| `tags` | Tags to assign to the CMK | `map(string)` | Yes | N/A |

## Outputs

| Name | Description |
|------|-------------|
| `key_vault_cmk_key_id` | The ID of the Customer-Managed Key |
| `key_vault_cmk_key_versionless_id` | The ID of the Customer-Managed Key Without version |
## Key Types and Sizes

### RSA Keys

| Key Size | Security Level | Use Case |
|----------|----------------|----------|
| 2048 bits | Standard | General purpose encryption, legacy systems |
| 3072 bits | Strong | Enhanced security requirements |
| 4096 bits | Maximum | Highly sensitive data, long-term storage, compliance |

**Recommended:** Use 4096-bit RSA keys for production CMK operations.

### Elliptic Curve (EC) Keys

| Key Size | Curve | Security Level | Use Case |
|----------|-------|----------------|----------|
| 256 bits | P-256 | Standard | Digital signatures, TLS certificates |
| 384 bits | P-384 | Strong | Enhanced security signatures |
| 521 bits | P-521 | Maximum | Long-term signature validity |

## Allowed Key Operations

The module supports the following key operations:

| Operation | Description | Use Case |
|-----------|-------------|----------|
| `encrypt` | Encrypt data | Data encryption at rest |
| `decrypt` | Decrypt data | Decryption of encrypted data |
| `sign` | Sign data | Digital signatures, authenticity |
| `verify` | Verify signatures | Signature validation |
| `wrapKey` | Wrap (encrypt) keys | Key encryption key (KEK) operations |
| `unwrapKey` | Unwrap (decrypt) keys | Key decryption operations |
| `import` | Import keys | External key import |
| `export` | Export keys | Key export (restricted in premium vaults) |
| `backup` | Backup keys | Key backup operations |
| `restore` | Restore keys | Key restoration from backup |
| `getRotationPolicy` | Get rotation policy | Read rotation settings |
| `setRotationPolicy` | Set rotation policy | Configure rotation |

## Key Rotation and Expiration Policies

### Rotation Policy Configuration

The module supports comprehensive key lifecycle management with three key timing parameters:

| Parameter | Description | Format | Example | Purpose |
|-----------|-------------|--------|---------|---------|
| `time_before_expiry` | Triggers automatic rotation before expiry | ISO 8601 | P30D | Rotate key 30 days before expiration |
| `notify_before_expiry` | Sends notification before expiry | ISO 8601 | P7D | Alert 7 days before expiration |
| `expire_after` | Total key lifetime until expiration | ISO 8601 | P365D | Key expires 365 days after creation |

### Timing Format

Use ISO 8601 duration format for all timing parameters:

| Format | Duration | Use Case |
|--------|----------|----------|
| `P7D` | 7 days | Aggressive notifications/rotation |
| `P14D` | 14 days | Frequent rotation/notifications |
| `P30D` | 30 days | Standard rotation trigger |
| `P60D` | 60 days | Extended rotation window |
| `P90D` | 90 days | Conservative rotation |
| `P180D` | 180 days | Long-term archive keys |
| `P365D` | 365 days | Annual expiration (1 year) |
| `P730D` | 730 days | 2-year expiration |
| `P1095D` | 1095 days | 3-year expiration |

### Recommended Configurations

#### High-Security Production
```hcl
time_before_expiry   = "P30D"      # Rotate 30 days before expiry
notify_before_expiry = "P7D"       # Alert 7 days before expiry
expire_after         = "P365D"     # Annual key rotation
```

#### Standard Production
```hcl
time_before_expiry   = "P60D"      # Rotate 60 days before expiry
notify_before_expiry = "P14D"      # Alert 14 days before expiry
expire_after         = "P730D"     # 2-year key lifetime
```

#### Long-Term Archive
```hcl
time_before_expiry   = "P90D"      # Rotate 90 days before expiry
notify_before_expiry = "P30D"      # Alert 30 days before expiry
expire_after         = "P1095D"    # 3-year expiration for archives
```

### Rotation Policy Timeline Example

```
Day 0: Key Created
├─ Expiration Date: Day 365
├─ Notify Date: Day 358 (expire_after - notify_before_expiry)
└─ Rotation Date: Day 335 (expire_after - time_before_expiry)

Day 335: Automatic Rotation Triggered
├─ New key version created
├─ Existing key remains valid for 30 more days
└─ Services can transition to new key version

Day 358: Notification Sent
├─ Admin receives notification
├─ Alert about impending key expiration
└─ Opportunity to extend timeline

Day 365: Key Expires
├─ Key can no longer be used for new operations
├─ Existing encrypted data remains readable
└─ Services must use rotated key version
```

### Best Practices for Rotation

1. **Early Rotation Trigger**: Set `time_before_expiry` well before expiration (30-90 days)
2. **Early Notifications**: Set `notify_before_expiry` earlier than rotation to allow planning
3. **Reasonable Expiration**: Set `expire_after` based on key type and sensitivity (1-3 years typical)
4. **Monitoring**: Monitor rotation events and key usage patterns
5. **Testing**: Test key rotation in non-production before production deployment

## Azure Services Supporting CMK

| Service | Resource Type | Supported | CMK Required |
|---------|---------------|-----------|--------------|
| **Storage** | Storage Account | ✅ | Optional |
| **SQL** | SQL Server (TDE) | ✅ | Optional |
| **CosmosDB** | Cosmos DB | ✅ | Optional |
| **Cache** | Redis Cache | ✅ | Optional |
| **Backup** | Recovery Services Vault | ✅ | Optional |
| **App Service** | Web Apps, Functions | ⚠️ | Limited |
| **Logic Apps** | Logic Apps | ✅ | Optional |
| **Event Grid** | Topics | ✅ | Optional |
| **Service Bus** | Namespaces | ✅ | Optional |

## Security Best Practices

### Key Management
1. **Use Premium Key Vault**: Deploy keys in Premium tier for enhanced security
2. **RBAC Controls**: Restrict key operations with fine-grained RBAC roles
3. **Private Key Vault**: Disable public access to the Key Vault
4. **Network Isolation**: Use private endpoints for Key Vault access

### Key Configuration
1. **Key Size**: Use 4096-bit RSA keys for maximum security
2. **Key Operations**: Limit operations to only what's needed
3. **Rotation Policy**: Enable automatic rotation (30 days before expiry recommended)
4. **Notification Timing**: Set notifications well before expiration (7-14 days)
5. **Expiration Duration**: Set appropriate key lifetime (1-3 years based on risk profile)

### Operations
1. **Key Auditing**: Enable diagnostic logging for key operations
2. **Access Monitoring**: Monitor who accesses and uses the CMK
3. **Backup Strategy**: Maintain secure key backups
4. **Incident Response**: Have procedures for key compromise

### Compliance
1. **Regulatory Requirements**: Ensure CMK usage meets compliance standards
2. **Data Residency**: Keep keys in compliant regions
3. **Audit Trails**: Maintain complete audit logs of key usage
4. **Documentation**: Document key management procedures

## Common Use Cases

### 1. Storage Account Encryption

```hcl
module "storage_cmk" {
  source = "./modules/key-vault-cmk"
  
  name                   = "key-storage-prod"
  key_vault_id           = module.key_vault.id
  key_type               = "RSA"
  key_size               = 4096
  key_opts               = ["encrypt", "decrypt", "wrapKey", "unwrapKey"]
  time_before_expiry     = "P30D"
  notify_before_expiry   = "P7D"
  expire_after           = "P365D"
  
  tags = local.tags
}

# Use in storage account
resource "azurerm_storage_account_customer_managed_key" "example" {
  storage_account_id = azurerm_storage_account.sa.id
  key_vault_key_id   = module.storage_cmk.key_vault_cmk_key_id
}
```

### 2. SQL Server Transparent Data Encryption (TDE)

```hcl
module "sql_cmk" {
  source = "./modules/key-vault-cmk"
  
  name                   = "key-sql-prod"
  key_vault_id           = module.key_vault.id
  key_type               = "RSA"
  key_size               = 4096
  key_opts               = ["wrapKey", "unwrapKey"]
  time_before_expiry     = "P30D"
  notify_before_expiry   = "P7D"
  expire_after           = "P365D"
  
  tags = local.tags
}

# Use in SQL Server TDE
resource "azurerm_mssql_server_transparent_data_encryption" "example" {
  server_id        = azurerm_mssql_server.sql.id
  key_vault_key_id = module.sql_cmk.key_vault_cmk_key_id
}
```

### 3. Cosmos DB Encryption

```hcl
module "cosmos_cmk" {
  source = "./modules/key-vault-cmk"
  
  name                   = "key-cosmos-prod"
  key_vault_id           = module.key_vault.id
  key_type               = "RSA"
  key_size               = 4096
  key_opts               = ["wrapKey", "unwrapKey"]
  time_before_expiry     = "P30D"
  notify_before_expiry   = "P7D"
  expire_after           = "P365D"
  
  tags = local.tags
}

# Use in Cosmos DB
resource "azurerm_cosmosdb_account" "example" {
  # ... other config
  
  customer_managed_key {
    key_vault_key_id = module.cosmos_cmk.key_vault_cmk_key_id
  }
}
```

## Troubleshooting

### Issue: Cannot Access CMK Key

**Possible Causes:**
- Insufficient RBAC permissions
- Key Vault firewall blocking access
- Service principal not authorized

**Solutions:**
```bash
# Check RBAC permissions
az role assignment list --resource-group <rg> \
  --filter "principalId eq '<principal-id>'"

# Verify Key Vault access
az keyvault secret list --vault-name <vault-name>

# Grant required permissions
az keyvault set-policy --name <vault-name> \
  --object-id <object-id> \
  --key-permissions get list create update delete import backup restore
```

### Issue: Key Rotation Failed

**Possible Causes:**
- Invalid rotation policy format
- Key already expired
- Permissions not granted for rotation

**Solutions:**
```bash
# Check current rotation policy
az keyvault key show --vault-name <vault> --name <key>

# Manually rotate key
az keyvault key rotate --vault-name <vault> --name <key>

# Update rotation policy
az keyvault key rotation-policy update --vault-name <vault> \
  --key-name <key> --value <policy.json>
```

### Issue: CMK Not Working with Service

**Possible Causes:**
- Service doesn't have permission to use the key
- Incorrect key ID format
- Service not authorized in Key Vault policy

**Solutions:**
1. Verify service identity has Key Vault access
2. Check Key Vault firewall rules
3. Ensure service can perform required key operations

## Cost Considerations

### Pricing Components

- **Key Vault Operations**: ~$0.03 per 10,000 operations
- **Premium Tier**: ~$1 per month (includes HSM-backed keys)
- **Key Storage**: Included with Premium tier
- **API Calls**: Minimal cost for key operations

### Cost Optimization

1. **Operation Consolidation**: Batch key operations when possible
2. **Key Lifecycle**: Set appropriate expiration dates
3. **Access Patterns**: Optimize how services access keys
4. **Monitoring**: Use diagnostics to understand usage patterns

## Integration with Other Modules

### With Key Vault Module
```hcl
module "key_vault" {
  source = "./modules/key-vault"
  # ... configuration
}

module "cmk_key" {
  source = "./modules/key-vault-cmk"
  
  key_vault_id = module.key_vault.key_vault_id
  # ... rest of configuration
  
  depends_on = [module.key_vault]
}
```

### With Storage Account
```hcl
module "cmk_key" {
  source = "./modules/key-vault-cmk"
  # ... configuration
}

resource "azurerm_storage_account_customer_managed_key" "sa" {
  storage_account_id = azurerm_storage_account.sa.id
  key_vault_key_id   = module.cmk_key.key_vault_cmk_key_id
  
  depends_on = [module.cmk_key]
}
```

## Related Modules

- [Key Vault](../key-vault/readme.md) - Container for CMK keys
- [Storage Account](../storage-account/readme.md) - Service using CMK for encryption
- [SQL Database](../sql-database/readme.md) - Service using CMK for TDE
- [Log Analytics Workspaces](../log-analytics-workspaces/readme.md) - For audit logging

## Additional Resources

- [Azure Key Vault CMK Documentation](https://learn.microsoft.com/en-us/azure/storage/common/customer-managed-keys-overview)
- [Key Vault Key Rotation](https://learn.microsoft.com/en-us/azure/key-vault/keys/how-to-configure-key-rotation)
- [Key Vault Best Practices](https://learn.microsoft.com/en-us/azure/key-vault/general/best-practices)
- [Cryptography Standards](https://learn.microsoft.com/en-us/azure/security/fundamentals/encryption-models)

## Notes

- Automatic rotation is triggered at the specified time before expiry
- Key operations must be specified during creation
- Keys can be imported from external sources
- Key versioning is automatic with each update
- Deleting a CMK key soft-deletes it (recoverable for 90 days)
- Services using CMK keys must have appropriate Key Vault access
