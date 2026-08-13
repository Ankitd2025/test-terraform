# Azure Disk Encryption Set Module

This Terraform module creates an Azure Disk Encryption Set with customer-managed keys (CMK) from Azure Key Vault, enabling enhanced encryption control and compliance requirements like PCI DSS.

## Description

Azure Disk Encryption Set allows you to manage disk encryption keys centrally using customer-managed keys (CMK) stored in Azure Key Vault. This module simplifies the deployment of managed encryption sets with automatic key rotation, providing better security posture and compliance capabilities for regulated environments.

## Features

- ✅ Customer-managed encryption keys (CMK) from Azure Key Vault
- ✅ Automatic key rotation enabled by default
- ✅ System-assigned managed identity for key access
- ✅ Support for OS disks and data disks encryption
- ✅ PCI DSS and regulatory compliance ready
- ✅ Regional deployment flexibility
- ✅ Comprehensive tagging support
- ✅ Automatic rotation of encryption keys for enhanced security

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
| `azurerm_disk_encryption_set` | The disk encryption set with customer-managed key |

## Prerequisites

Before using this module, you must have:

1. **Azure Key Vault** with a key for disk encryption
   - Key Vault must be in the same region as the Disk Encryption Set
   - Key Vault access policies must allow the Disk Encryption Set's managed identity to use the key
   
2. **Key Vault Key**
   - Must be an RSA key (2048, 3072, or 4096 bits recommended)
   - Should have key operations: Encrypt, Decrypt, Wrapkey, UnwrapKey, Get, List

3. **Permissions Setup**
   - Grant the Disk Encryption Set's managed identity (principal ID) permission to access the Key Vault key
   - Use `Get`, `Decrypt`, `Encrypt`, `UnwrapKey`, `WrapKey`, and `List` permissions

## Usage

### Basic Disk Encryption Set with CMK

```hcl
module "disk_encryption_set" {
  source = "./modules/disk-encryption-set"
  
  name                = "des-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  key_vault_key_id    = module.key_vault.encryption_key_id
  
  tags = {
    Environment = "Production"
    Compliance  = "PCI-DSS"
    ManagedBy   = "Terraform"
  }
}
```

### Complete Example with Key Vault Setup

```hcl
# Create Key Vault for encryption keys
resource "azurerm_key_vault" "encryption_vault" {
  name                        = "kv-encryption-prod-001"
  location                    = "eastus"
  resource_group_name         = module.resource_group.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium"
  
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    
    key_permissions = [
      "Get",
      "Create",
      "Delete",
      "List",
      "Restore",
      "Recover",
      "UnwrapKey",
      "WrapKey",
      "Purge",
      "Encrypt",
      "Decrypt",
      "Sign",
      "Verify",
    ]
  }
}

# Create encryption key in Key Vault
resource "azurerm_key_vault_key" "disk_encryption_key" {
  name            = "disk-encryption-key"
  key_vault_id    = azurerm_key_vault.encryption_vault.id
  key_type        = "RSA"
  key_size        = 2048
  
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

# Create Disk Encryption Set
module "disk_encryption_set" {
  source = "./modules/disk-encryption-set"
  
  name                = "des-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  key_vault_key_id    = azurerm_key_vault_key.disk_encryption_key.id
  
  tags = {
    Environment = "Production"
    Compliance  = "PCI-DSS"
    ManagedBy   = "Terraform"
  }
}

# Grant Disk Encryption Set access to Key Vault
resource "azurerm_key_vault_access_policy" "disk_encryption_set_policy" {
  key_vault_id = azurerm_key_vault.encryption_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = module.disk_encryption_set.disk_encryption_set_identity_principal_id
  
  key_permissions = [
    "Get",
    "Decrypt",
    "Encrypt",
    "UnwrapKey",
    "WrapKey",
    "List",
  ]
}
```

### Using Disk Encryption Set with VMs

```hcl
# Disk Encryption Set
module "disk_encryption_set" {
  source = "./modules/disk-encryption-set"
  
  name                = "des-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  key_vault_key_id    = azurerm_key_vault_key.disk_encryption_key.id
  
  tags = {
    Environment = "Production"
    Compliance  = "PCI-DSS"
  }
}

# PCI-Compliant Linux VM using the encryption set
module "linux_vm" {
  source = "./modules/linux-virtual-machine"
  
  name                = "vm-app-prod-eastus-001"
  resource_group_name = module.resource_group.resource_group_name
  location            = "eastus"
  admin_username      = "azureuser"
  admin_ssh_public_key = file("~/.ssh/id_rsa.pub")
  
  vnet_id  = module.vnet.id
  subnet_id = module.subnet.id
  
  # Enable disk encryption with the encryption set
  enable_disk_encryption = true
  disk_encryption_set_id = module.disk_encryption_set.disk_encryption_set_id
  
  # Data disks also encrypted with the same encryption set
  data_disk_count = 2
  
  tags = {
    Environment = "Production"
    Compliance  = "PCI-DSS"
  }
}

# Managed disks using the encryption set
resource "azurerm_managed_disk" "data_disk" {
  count               = 3
  name                = "disk-data-prod-eastus-${count.index + 1}"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  
  storage_account_type  = "Premium_LRS"
  create_option         = "Empty"
  disk_size_gb          = 256
  disk_encryption_set_id = module.disk_encryption_set.disk_encryption_set_id
  
  tags = {
    Environment = "Production"
    Compliance  = "PCI-DSS"
  }
}
```

### Multi-Region Encryption Set Deployment

```hcl
# Encryption Set for East US
module "disk_encryption_set_east" {
  source = "./modules/disk-encryption-set"
  
  name                = "des-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group_east.resource_group_name
  key_vault_key_id    = azurerm_key_vault_key.disk_encryption_key_east.id
  
  tags = {
    Environment = "Production"
    Region      = "East US"
    Compliance  = "PCI-DSS"
  }
}

# Encryption Set for West US
module "disk_encryption_set_west" {
  source = "./modules/disk-encryption-set"
  
  name                = "des-prod-westus-001"
  location            = "westus"
  resource_group_name = module.resource_group_west.resource_group_name
  key_vault_key_id    = azurerm_key_vault_key.disk_encryption_key_west.id
  
  tags = {
    Environment = "Production"
    Region      = "West US"
    Compliance  = "PCI-DSS"
  }
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | The name of the Disk Encryption Set | `string` | Yes | n/a |
| location | The Azure region where the Disk Encryption Set will be created | `string` | Yes | n/a |
| resource_group_name | The name of the resource group | `string` | Yes | n/a |
| key_vault_key_id | The ID of the Key Vault key to use for encryption (must be RSA, 2048-4096 bits) | `string` | Yes | n/a |
| tags | A map of tags to assign to the Disk Encryption Set | `map(string)` | No | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| disk_encryption_set_id | The ID of the Disk Encryption Set |
| disk_encryption_set_name | The name of the Disk Encryption Set |
| disk_encryption_set_identity_principal_id | The principal ID (object ID) of the system-assigned managed identity |

## Key Vault Configuration

### Required Key Vault Properties

```hcl
resource "azurerm_key_vault" "encryption" {
  # Enable for disk encryption
  enabled_for_disk_encryption = true
  
  # Premium SKU (recommended for production)
  sku_name = "premium"
  
  # Soft-delete and purge protection (recommended)
  soft_delete_retention_days = 90
  purge_protection_enabled   = true
}
```

### Required Key Vault Access Policies

The Disk Encryption Set's managed identity requires these key permissions:

- **Get** - Retrieve key metadata
- **Decrypt** - Decrypt data
- **Encrypt** - Encrypt data
- **UnwrapKey** - Unwrap (decrypt) key-wrapped secrets
- **WrapKey** - Wrap (encrypt) secrets with the key
- **List** - List keys in the vault

### Recommended Key Vault Configuration

```hcl
resource "azurerm_key_vault_access_policy" "disk_encryption" {
  key_vault_id = azurerm_key_vault.encryption.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = module.disk_encryption_set.disk_encryption_set_identity_principal_id
  
  key_permissions = [
    "Get",
    "Decrypt",
    "Encrypt",
    "UnwrapKey",
    "WrapKey",
    "List",
  ]
}
```

## Key Vault Key Specifications

### Supported Key Types

- **RSA** - Recommended for disk encryption
  - Key sizes: 2048, 3072, 4096 bits
  - Recommended: 2048 or 4096 bits

### Key Operations Required

The Key Vault key must support these operations:

```hcl
key_opts = [
  "decrypt",
  "encrypt",
  "sign",
  "unwrapKey",
  "verify",
  "wrapKey",
]
```

### Creating a Disk Encryption Key

```hcl
resource "azurerm_key_vault_key" "disk_encryption" {
  name            = "disk-encryption-key"
  key_vault_id    = azurerm_key_vault.encryption.id
  key_type        = "RSA"
  key_size        = 4096  # Strong encryption
  
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  
  depends_on = [
    azurerm_key_vault_access_policy.terraform
  ]
}
```

## Automatic Key Rotation

This module enables automatic key rotation by default, which:

- **Automatically rotates** the Key Vault key to the latest version
- **Maintains compatibility** with disks encrypted using previous key versions
- **Improves security** by regularly updating encryption keys
- **Requires no downtime** for encryption key updates

### Important Notes on Key Rotation

1. **Old Key Versions Remain Valid**: Disks encrypted with previous key versions continue to work
2. **Automatic Migration**: New disks use the latest key version
3. **No Re-encryption Required**: Existing disks don't need re-encryption
4. **Key Versioning**: Azure Key Vault automatically versions keys

## Compliance & Security

### PCI DSS Compliance

This module helps meet PCI DSS 3.4 requirements for encryption:

- ✅ Customer-managed encryption keys (CMK) for enhanced control
- ✅ Key stored in secure Key Vault with access policies
- ✅ Automatic key rotation for key management
- ✅ Audit logging of key usage in Key Vault
- ✅ System-assigned managed identity prevents credential exposure

### Security Best Practices

1. **Use Premium Key Vault**: Better security and performance for production
2. **Enable Purge Protection**: Prevent accidental key deletion
3. **Enable Soft Delete**: Recover accidentally deleted keys
4. **Restrict Access**: Limit Key Vault access to authorized services
5. **Monitor Key Usage**: Enable Key Vault diagnostics and monitoring
6. **Rotate Keys Regularly**: Let automatic rotation handle this
7. **Strong Key Sizes**: Use RSA-4096 for highest security
8. **Regional Placement**: Keep encryption set in same region as resources

## Naming Conventions

When naming Disk Encryption Sets, follow [Azure naming conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming):

- **Length**: 1-80 characters
- **Valid characters**: Alphanumerics, hyphens
- **Start with**: Alphanumeric
- **End with**: Alphanumeric
- **Recommended pattern**: `des-<environment>-<region>-<instance>`

### Examples

- `des-prod-eastus-001` - Production in East US
- `des-dev-westus-001` - Development in West US
- `des-pci-eastus-001` - PCI-compliant production in East US

## Troubleshooting

### Common Issues

**Issue**: Access Denied when using Disk Encryption Set
- **Solution**:
  1. Verify Key Vault access policy is configured for the Disk Encryption Set's principal ID
  2. Ensure the principal ID is correct: `module.disk_encryption_set.disk_encryption_set_identity_principal_id`
  3. Verify Key Vault allows disk encryption: `enabled_for_disk_encryption = true`
  4. Check Key Vault is in the same region as the Disk Encryption Set

**Issue**: Invalid key_vault_key_id format
- **Solution**:
  1. Key vault key ID format: `/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.KeyVault/vaults/{vault}/keys/{key}/versions/{version}`
  2. Use full key ID including version: `azurerm_key_vault_key.key.id`
  3. Don't use just the key name or vault URL

**Issue**: Key not found or doesn't exist
- **Solution**:
  1. Verify the Key Vault exists in the same region
  2. Confirm the key exists in the Key Vault
  3. Check key operations include required operations (Encrypt, Decrypt, WrapKey, UnwrapKey)
  4. Ensure key is enabled (not disabled)

**Issue**: Cannot create disk with encryption set
- **Solution**:
  1. Verify Disk Encryption Set is fully created before creating disks
  2. Check VM size supports managed disks with encryption
  3. Ensure region supports Disk Encryption Sets
  4. Verify Key Vault access policy is active

### Validation Commands

```powershell
# Show Disk Encryption Set details
az disk-encryption-set show --name des-prod-eastus-001 \
  --resource-group rg-prod-001

# List all Disk Encryption Sets in resource group
az disk-encryption-set list --resource-group rg-prod-001 --output table

# Check Disk Encryption Set identity
az disk-encryption-set show --name des-prod-eastus-001 \
  --resource-group rg-prod-001 \
  --query identity

# Verify Key Vault access policy
az keyvault access-policy list --vault-name kv-encryption-prod \
  --output table

# Check key permissions
az keyvault key show --vault-name kv-encryption-prod \
  --name disk-encryption-key

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
terrascan scan -d .\modules\disk-encryption-set\ -i terraform

# Lint check
tflint --init
tflint
```

## Notes

- **Regional Requirement**: Disk Encryption Set must be in the same region as resources using it
- **Key Vault SKU**: Premium SKU recommended for production (supports key rotation)
- **System-Assigned Identity**: Automatically managed by Azure for key access
- **Key Versioning**: Key Vault automatically maintains key versions for rotation
- **Costs**: Disk Encryption Sets have associated costs; check Azure pricing
- **Disks Cannot Be Changed**: Encryption set cannot be changed after disk creation
- **Managed Disks Only**: Works with managed disks, not with unmanaged storage
- **Performance**: No performance impact from CMK encryption
- **Failover**: Disks remain encrypted during failover/replication

## Module Maintenance

### Version History

- **v1.0.0** - Initial release
  - Disk Encryption Set creation with CMK
  - Automatic key rotation enabled
  - System-assigned managed identity
  - Comprehensive tagging support

### Contributing

When contributing to this module:
1. Run `terraform fmt` to format code
2. Run `terraform validate` to check syntax
3. Test with different key vault configurations
4. Verify Key Vault access policies work correctly
5. Test with managed disks and VMs
6. Verify automatic key rotation doesn't cause issues
7. Run security scans with Terrascan or tfsec
8. Update documentation for any new variables or outputs
9. Test in non-production environment first

## References

- [Azure Disk Encryption Set Documentation](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/disk-encryption-overview)
- [Azure Key Vault Documentation](https://learn.microsoft.com/en-us/azure/key-vault/)
- [Customer-Managed Keys for Managed Disks](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/disk-encryption)
- [PCI DSS Compliance on Azure](https://learn.microsoft.com/en-us/azure/compliance/offerings/offering-pci-dss)
- [Azure Managed Identities](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)
- [Key Vault Access Policies](https://learn.microsoft.com/en-us/azure/key-vault/general/assign-access-policy)
- [Terraform AzureRM Provider - Disk Encryption Set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/disk_encryption_set)
- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
