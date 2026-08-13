# Azure Role-Based Access Control (RBAC) Module

This Terraform module creates and manages Azure Role-Based Access Control (RBAC) role assignments, enabling fine-grained access control for users, groups, and service principals across Azure resources.

## Overview

Azure RBAC is Microsoft's authorization system for managing access to Azure resources. This module simplifies the assignment of built-in and custom roles to principals (users, groups, service principals) at various scope levels (subscription, resource group, individual resources).

## Features

- ✅ **Flexible Role Assignment** - Assign built-in and custom roles
- ✅ **Multiple Scope Levels** - Support for subscription, resource group, and resource-level scoping
- ✅ **Multiple Principal Types** - Users, groups, managed identities, and service principals
- ✅ **Easy Reusability** - Single module for multiple role assignments
- ✅ **Role Definition by Name** - Reference roles by friendly names (e.g., "Contributor", "Reader")
- ✅ **Scalable** - Supports bulk role assignment using for_each
- ✅ **Secure Access Control** - Enforce least-privilege access principles
- ✅ **Audit-Ready** - Full visibility into access assignments

## Prerequisites

- Azure subscription with appropriate permissions
- Terraform backend configured
- Permission to assign roles at the target scope (Owner or User Access Administrator)
- Valid principal IDs (user/group/service principal)

## Usage

### Basic Role Assignment - Contributor at Resource Group Level

```hcl
module "rbac_contributor" {
  source = "./modules/rbac"

  scope                = "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}"
  role_definition_name = "Contributor"
  principal_id         = "00000000-0000-0000-0000-000000000000"  # User/Group/SP Object ID
}
```

### Reader Role Assignment at Subscription Level

```hcl
module "rbac_reader" {
  source = "./modules/rbac"

  scope                = "/subscriptions/{subscriptionId}"
  role_definition_name = "Reader"
  principal_id         = data.azurerm_client_config.current.object_id
}
```

### Multiple Role Assignments with for_each

```hcl
locals {
  role_assignments = {
    dev_contributor = {
      scope     = "/subscriptions/{subscriptionId}/resourceGroups/rg-dev"
      role      = "Contributor"
      principal = "dev-team-group-id"
    }
    prod_reader = {
      scope     = "/subscriptions/{subscriptionId}/resourceGroups/rg-prod"
      role      = "Reader"
      principal = "prod-team-group-id"
    }
    storage_owner = {
      scope     = "/subscriptions/{subscriptionId}/resourceGroups/rg-storage/providers/Microsoft.Storage/storageAccounts/mystorageaccount"
      role      = "Storage Account Key Operator Service Role"
      principal = "app-service-principal-id"
    }
  }
}

module "rbac_assignments" {
  for_each = local.role_assignments

  source = "./modules/rbac"

  scope                = each.value.scope
  role_definition_name = each.value.role
  principal_id         = each.value.principal
}
```

### Managed Identity with Key Vault Access

```hcl
# Create managed identity
resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "app-identity"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "eastus"
}

# Assign Key Vault Administrator role
module "kv_admin_access" {
  source = "./modules/rbac"

  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azurerm_user_assigned_identity.app_identity.principal_id
}

# Assign Key Vault Secrets User role
module "kv_secrets_access" {
  source = "./modules/rbac"

  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app_identity.principal_id
}
```

### Team and Department Access Structure

```hcl
locals {
  teams = {
    platform = {
      group_id = "platform-team-group-id"
      role     = "Contributor"
      scopes = [
        "/subscriptions/{subscriptionId}/resourceGroups/rg-network",
        "/subscriptions/{subscriptionId}/resourceGroups/rg-compute"
      ]
    }
    data = {
      group_id = "data-team-group-id"
      role     = "Contributor"
      scopes = [
        "/subscriptions/{subscriptionId}/resourceGroups/rg-data",
        "/subscriptions/{subscriptionId}/resourceGroups/rg-analytics"
      ]
    }
    security = {
      group_id = "security-team-group-id"
      role     = "Security Administrator"
      scopes = [
        "/subscriptions/{subscriptionId}"
      ]
    }
  }
}

module "team_rbac" {
  for_each = merge([
    for team, config in local.teams : {
      for scope in config.scopes : "${team}-${scope}" => {
        scope     = scope
        role      = config.role
        principal = config.group_id
      }
    }
  ]...)

  source = "./modules/rbac"

  scope                = each.value.scope
  role_definition_name = each.value.role
  principal_id         = each.value.principal
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `scope` | The scope at which the role assignment applies (subscription, resource group, or resource) | `string` | Yes | N/A |
| `role_definition_name` | The name of the role to assign (e.g., 'Contributor', 'Reader', 'Owner') | `string` | Yes | N/A |
| `principal_id` | The principal ID of the user, group, or service principal | `string` | Yes | N/A |

## Outputs

This module does not produce outputs as it only creates role assignments.

## Scope Levels

### Subscription Scope

Assigns role to all resources within the subscription:

```hcl
scope = "/subscriptions/00000000-0000-0000-0000-000000000000"
```

### Resource Group Scope

Assigns role to all resources within the resource group:

```hcl
scope = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-name"
```

### Resource Scope

Assigns role to a specific resource:

```hcl
# Storage Account
scope = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-name/providers/Microsoft.Storage/storageAccounts/mystorageaccount"

# Key Vault
scope = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-name/providers/Microsoft.KeyVault/vaults/myvault"

# SQL Database
scope = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-name/providers/Microsoft.Sql/servers/myserver/databases/mydatabase"

# Virtual Machine
scope = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-name/providers/Microsoft.Compute/virtualMachines/myvm"
```

## Built-in Azure Roles

### Fundamental Roles

| Role | Description | Use Case |
|------|-------------|----------|
| **Owner** | Full access including role management | Subscription/Resource admins |
| **Contributor** | Full access except role management | Developers, operators |
| **Reader** | Read-only access | Auditors, stakeholders |

### Application-Specific Roles

| Role | Resource | Use Case |
|------|----------|----------|
| **Key Vault Administrator** | Key Vault | Full key vault access |
| **Key Vault Secrets User** | Key Vault | Read secrets only |
| **Key Vault Crypto User** | Key Vault | Encryption/decryption |
| **Storage Account Key Operator Service Role** | Storage | Manage storage keys |
| **Storage Blob Data Contributor** | Storage | Read/write blobs |
| **Storage Blob Data Reader** | Storage | Read blobs only |
| **SQL Server Contributor** | SQL Server | SQL server management |
| **SQL DB Contributor** | SQL DB | Database management |
| **Virtual Machine Contributor** | VM | Virtual machine management |
| **App Configuration Data Reader** | App Config | Read app settings |

### Azure Services Roles

| Role | Description |
|------|-------------|
| **Managed Identity Operator** | Create, read, update, delete managed identities |
| **User Access Administrator** | Manage user access to Azure resources |
| **Security Administrator** | View and manage security alerts |
| **Application Administrator** | Create and manage applications |

## Best Practices

### Security & Access Control
1. **Principle of Least Privilege** - Assign only necessary roles at the minimum scope
2. **Use Groups** - Assign roles to groups rather than individuals
3. **Use Managed Identities** - For Azure services, use managed identities instead of users
4. **Scope Minimization** - Use resource-level assignments when possible, not subscription-wide
5. **Regular Audits** - Review role assignments periodically

### Role Assignment Strategy
1. **Separate Dev/Test/Prod** - Use different resource groups and role assignments
2. **Environment-Based Roles** - Different roles for different environments
3. **Time-Limited Access** - Use Privileged Identity Management (PIM) for elevated roles
4. **Documentation** - Document the purpose of each role assignment
5. **Automation** - Use Terraform for consistent, auditable role assignments

### Implementation Patterns
1. **Team-Based Access** - Assign roles to team groups
2. **Application Service Principals** - Use dedicated service accounts for applications
3. **Resource-Level Permissions** - Restrict to specific resources when possible
4. **Custom Roles** - Create custom roles for specific organizational needs
5. **Cross-Tenant** - Use guest accounts for B2B collaboration

## Common Use Cases

### 1. Application Service Principal Access

```hcl
# Service Principal with Key Vault access
module "app_sp_kv_access" {
  source = "./modules/rbac"

  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azuread_service_principal.app.object_id
}

# Service Principal with Storage access
module "app_sp_storage_access" {
  source = "./modules/rbac"

  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.app.object_id
}
```

### 2. Developer Team Access

```hcl
module "dev_team_access" {
  source = "./modules/rbac"

  scope                = azurerm_resource_group.dev.id
  role_definition_name = "Contributor"
  principal_id         = azuread_group.dev_team.object_id
}

# Read-only access to production
module "dev_team_prod_reader" {
  source = "./modules/rbac"

  scope                = azurerm_resource_group.prod.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.dev_team.object_id
}
```

### 3. Operations Team Access

```hcl
module "ops_team_access" {
  source = "./modules/rbac"

  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "User Access Administrator"
  principal_id         = azuread_group.ops_team.object_id
}
```

### 4. Audit and Compliance Access

```hcl
module "compliance_reader" {
  source = "./modules/rbac"

  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Security Reader"
  principal_id         = azuread_group.compliance_team.object_id
}
```

### 5. Database Administrator Access

```hcl
module "dba_sql_access" {
  source = "./modules/rbac"

  scope                = azurerm_mssql_server.sql.id
  role_definition_name = "SQL Server Contributor"
  principal_id         = azuread_group.dba_team.object_id
}
```

## Troubleshooting

### Issue: Role Assignment Fails with "Authorization Failed"

**Possible Causes:**
- Insufficient permissions (not Owner or User Access Administrator)
- Invalid principal ID
- Wrong scope format
- Role name misspelled

**Solutions:**
```bash
# Verify current permissions
az role assignment list --assignee $(az ad signed-in-user show --query objectId -o tsv)

# Get correct role name
az role definition list --query "[?contains(roleName, 'Contributor')]"

# Verify principal exists
az ad user show --id <user-principal-name> --query objectId
az ad group show --group <group-name> --query objectId
az ad sp show --id <app-id> --query objectId
```

### Issue: "Principal Does Not Exist"

**Possible Causes:**
- Invalid object ID format
- Principal doesn't exist in the directory
- Wrong Azure AD tenant

**Solutions:**
```bash
# List all users
az ad user list --query "[].objectId"

# List all groups
az ad group list --query "[].objectId"

# List all service principals
az ad sp list --query "[].objectId"

# Get specific user/group ID
az ad user show --id user@example.com --query objectId
az ad group show --group "group-name" --query objectId
```

### Issue: Custom Role Assignment Not Working

**Possible Causes:**
- Role name is incorrect
- Role not available in the directory
- Role requires specific subscription

**Solutions:**
```bash
# List available roles
az role definition list --query "[].roleName" | sort

# Get role details
az role definition show --name "Custom Role Name"

# Verify role is in scope
az role definition list --scope "/subscriptions/{subscriptionId}"
```

## Role Assignment Scenarios

### Multi-Environment Setup

```hcl
locals {
  environments = ["dev", "test", "prod"]
  team_roles = {
    developers = "Contributor"
    operations = "User Access Administrator"
    readers    = "Reader"
  }
}

module "multi_env_rbac" {
  for_each = merge([
    for env in local.environments : {
      for role_key, role_name in local.team_roles : "${env}-${role_key}" => {
        rg_name   = "rg-${env}"
        role      = role_name
        principal = "oid-${role_key}-group"
      }
    }
  ]...)

  source = "./modules/rbac"

  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${each.value.rg_name}"
  role_definition_name = each.value.role
  principal_id         = each.value.principal
}
```

### Role Hierarchy

```hcl
# Subscription level (highest privilege)
module "sub_admin" {
  source = "./modules/rbac"

  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Owner"
  principal_id         = "admin-group-id"
}

# Resource group level
module "rg_contributor" {
  source = "./modules/rbac"

  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = "team-group-id"
}

# Resource level (least privilege)
module "resource_reader" {
  source = "./modules/rbac"

  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = "app-service-principal-id"
}
```

## Integration with Other Modules

### With Managed Identity

```hcl
module "app_identity" {
  source = "./modules/managed-identity"
  # ... configuration
}

module "app_kv_access" {
  source = "./modules/rbac"

  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.app_identity.principal_id
}
```

### With Key Vault

```hcl
module "key_vault" {
  source = "./modules/key-vault"
  # ... configuration
}

module "app_access_kv" {
  source = "./modules/rbac"

  scope                = module.key_vault.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azuread_service_principal.app.object_id
}
```

## Related Modules

- [Managed Identity](../managed-identity/readme.md) - For creating service principals and identities
- [Key Vault](../key-vault/readme.md) - For securing secrets and keys
- [Resource Group](../resource-group/readme.md) - For organizing resources

## Additional Resources

- [Azure RBAC Documentation](https://learn.microsoft.com/en-us/azure/role-based-access-control/)
- [Built-in Roles Reference](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles)
- [Custom Roles Documentation](https://learn.microsoft.com/en-us/azure/role-based-access-control/custom-roles)
- [Azure Governance Best Practices](https://learn.microsoft.com/en-us/azure/governance/azure-management/governance-in-azure)

## Notes

- Role assignments take effect immediately
- Role names are case-sensitive
- Use resource IDs for precise scope specification
- Can be used with Azure CLI: `az role assignment create`
- Supports both built-in and custom roles
- Role assignments are tracked in Activity Logs
- Use PIM for time-limited elevated access
