# Azure Key Vault Module

This Terraform module creates and configures an Azure Key Vault instance with support for RBAC authorization, diagnostic logging, and network access controls.

## Overview

The Key Vault module provisions a secure key management service on Azure with built-in support for:
- RBAC-based access control
- Diagnostic monitoring and logging
- Public network access configuration
- Soft delete retention policies
- Role assignments for Key Vault administrators

## Usage

### Basic Example

```hcl
module "key_vault" {
  source = "./modules/key-vault"

  name                = "kv-myapp-prod"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  purge_protection_enabled = true
  tags                = local.common_tags

  principal_id = azurerm_user_assigned_identity.app_identity.principal_id
}
```

### With Diagnostic Logging

```hcl
module "key_vault" {
  source = "./modules/key-vault"

  name                         = "kv-myapp-prod"
  location                     = "eastus"
  resource_group_name          = azurerm_resource_group.rg.name
  tenant_id                    = data.azurerm_client_config.current.tenant_id
  sku_name                     = "standard"
  public_network_access_enabled = false
  rbac_authorization_enabled   = true
  soft_delete_retention_days   = 90
  purge_protection_enabled     = true
  tags                         = local.common_tags

  enable_diagnostic              = true
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.law.id
  principal_id                   = azurerm_user_assigned_identity.app_identity.principal_id
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the Key Vault | `string` | N/A | Yes |
| `location` | The Azure region for the Key Vault | `string` | N/A | Yes |
| `resource_group_name` | Name of the resource group | `string` | N/A | Yes |
| `tenant_id` | The tenant ID of the Key Vault | `string` | N/A | Yes |
| `sku_name` | The SKU name (standard or premium) | `string` | N/A | Yes |
| `principal_id` | RBAC Policy principal ID for Key Vault Administrator role assignment | `string` | N/A | Yes |
| `public_network_access_enabled` | Enable public network access | `bool` | `false` | No |
| `purge_protection_enabled` | Enable purge protection for the Key Vault | `bool` | N/A | Yes |
| `rbac_authorization_enabled` | Enable RBAC authorization | `bool` | `true` | No |
| `soft_delete_retention_days` | Retention days for soft-deleted Key Vaults | `number` | `90` | No |
| `enable_diagnostic` | Enable diagnostic settings | `bool` | `false` | No |
| `log_analytics_workspace_id` | Log Analytics workspace resource ID for diagnostics | `string` | N/A | Conditional* |
| `tags` | Tags to assign to the Key Vault | `map(string)` | N/A | Yes |

*Required when `enable_diagnostic` is set to `true`.

## Outputs

| Name | Description |
|------|-------------|
| `key_vault_id` | The ID of the Key Vault |
| `key_vault_name` | The name of the Key Vault |
| `key_vault_location` | The location of the Key Vault |

## Features

### Security
- **RBAC Authorization**: Supports Azure Role-Based Access Control for fine-grained permissions
- **Network Access Control**: Configure public network access with `public_network_access_enabled`
- **Soft Delete Protection**: Retains deleted Key Vaults for recovery (default 90 days)
- **Role Assignment**: Automatically assigns Key Vault Administrator role to specified principal

### Monitoring
- **Diagnostic Logging**: Optional integration with Log Analytics workspace
- **Audit Logs**: Captures all audit events when diagnostics are enabled
- **Metrics**: Tracks Key Vault performance metrics

### Modules Included
- **main.tf**: Primary Key Vault resource configuration
- **rbac.tf**: Role-based access control assignments
- **diagnostic.tf**: Optional diagnostic settings and monitoring
- **variables.tf**: Input variable definitions
- **outputs.tf**: Output value definitions

## Best Practices

1. **Network Security**: Set `public_network_access_enabled = false` for production environments and use private endpoints
2. **RBAC**: Enable `rbac_authorization_enabled = true` for modern access control (recommended over vault access policies)
3. **Monitoring**: Enable diagnostic logging in production to track access and changes
4. **Naming**: Follow Azure naming conventions (e.g., `kv-{appname}-{env}`)
5. **SKU Selection**: Use `premium` SKU if you require HSM-backed keys
6. **Principal ID**: Ensure the `principal_id` corresponds to a valid Azure identity (service principal, managed identity, or user)
7. **Retention Policy**: Adjust `soft_delete_retention_days` based on organizational compliance requirements

## Notes

- This module requires the specified principal to have sufficient permissions to be assigned the Key Vault Administrator role
- Ensure the Log Analytics workspace specified in `log_analytics_workspace_id` exists in the same subscription
- The Key Vault name must be globally unique across Azure
- Key Vault names must be between 3-24 characters and contain only alphanumeric and dashes
- **Purge Protection**: When `purge_protection_enabled = true`, the Key Vault cannot be purged and must be soft-deleted first before permanent deletion
- When `enable_diagnostic = true`, both audit and all log categories are enabled for comprehensive monitoring

## Related Modules

- [Log Analytics Workspaces](../log-analytics-workspaces/readme.md) - For monitoring and diagnostics
- [Resource Group](../resource-group/readme.md) - For resource organization
