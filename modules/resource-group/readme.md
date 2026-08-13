# Azure Resource Group Module

This Terraform module creates an Azure Resource Group with configurable name, location, and tags.

## Description

A Resource Group is a container that holds related resources for an Azure solution. This module provides a simple, reusable way to create resource groups with consistent naming and tagging across your infrastructure.

## Usage

### Basic Example

```hcl
module "resource_group" {
  source   = "./modules/resource-group"
  
  name     = "rg-incumbentfi-prod-eastus-001"
  location = "East US"
  tags = {
    Environment = "Production"
    Project     = "IncumbentFI"
    ManagedBy   = "Terraform"
  }
}
```

### Multiple Resource Groups

```hcl
module "app_resource_group" {
  source   = "./modules/resource-group"
  
  name     = "rg-incumbentfi-app-prod-eastus-001"
  location = "East US"
  tags = {
    Environment = "Production"
    Tier        = "Application"
    Project     = "IncumbentFI"
  }
}

module "data_resource_group" {
  source   = "./modules/resource-group"
  
  name     = "rg-incumbentfi-data-prod-eastus-001"
  location = "East US"
  tags = {
    Environment = "Production"
    Tier        = "Data"
    Project     = "IncumbentFI"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | The name of the resource group | `string` | Yes | n/a |
| location | The Azure region where the resource group will be created | `string` | Yes | n/a |
| tags | A map of tags to assign to the resource group | `map(string)` | Yes | n/a |

## Outputs

| Name | Description |
|------|-------------|
| resource_group_id | The ID of the resource group |
| resource_group_name | The name of the resource group |
| resource_group_location | The location of the resource group |
| resource_group_tags | The tags assigned to the resource group |

## Azure Naming Conventions

When naming resource groups, follow [Azure naming conventions](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules):

- **Length**: 1-90 characters
- **Valid characters**: Alphanumerics, underscores, parentheses, hyphens, periods (except at end)
- **Recommended pattern**: `rg-<application>-<environment>-<region>-<instance>`

### Examples

- `rg-incumbentfi-prod-eastus-001`
- `rg-incumbentfi-dev-westus2-001`
- `rg-shared-services-prod-centralus-001`

## Notes

- Resource groups are free in Azure; you only pay for resources within them
- All resources in a resource group should share the same lifecycle
- Resource groups cannot be nested
- Deleting a resource group deletes all resources within it
- Resources can be moved between resource groups after creation

## Best Practices

1. **Consistent Tagging**: Always include tags for Environment, Project, and ManagedBy
2. **Naming Convention**: Use a consistent naming pattern across all resource groups
3. **Regional Placement**: Consider data residency and compliance requirements
4. **Lifecycle Management**: Group resources that share the same lifecycle
5. **Access Control**: Use Azure RBAC at the resource group level for access management

## Example with All Recommended Tags

```hcl
module "resource_group" {
  source   = "./modules/resource-group"
  
  name     = "rg-incumbentfi-prod-eastus-001"
  location = "East US"
  
  tags = {
    Environment     = "Production"
    Project         = "IncumbentFI"
    ManagedBy       = "Terraform"
    Owner           = "Platform Team"
    CostCenter      = "CC-12345"
    BusinessUnit    = "Financial Services"
    DataClass       = "Confidential"
    Compliance      = "PCI-DSS"
    BackupPolicy    = "Daily"
    MaintenanceWindow = "Sun:02:00-06:00"
  }
}
```

## Security and Compliance

### Resource Group Security

- **Access Control**: Implement Azure RBAC (Role-Based Access Control) at the resource group level
- **Resource Locks**: Consider applying CanNotDelete or ReadOnly locks to prevent accidental deletion
- **Azure Policy**: Apply policies at the resource group level for governance and compliance
- **Activity Logs**: Monitor resource group operations through Azure Activity Logs

### Compliance Scanning

This module has been scanned with Terrascan for security and compliance issues:

```powershell
terrascan scan -d .\modules\resource-group\ -i terraform
```

Regular scanning helps ensure:
- Security best practices are followed
- Compliance requirements are met
- Infrastructure as Code vulnerabilities are identified early

## Module Validation

### Pre-deployment Validation

Before deploying this module, validate your configuration:

```powershell
# Initialize Terraform
terraform init

# Validate syntax and configuration
terraform validate

# Plan deployment
terraform plan

# Security scan with Terrascan
terrascan scan -d .\modules\resource-group\ -i terraform
```
## Advanced Usage

### Resource Group with Locks

```hcl
module "resource_group" {
  source   = "./modules/resource-group"
  
  name     = "rg-incumbentfi-prod-eastus-001"
  location = "East US"
  tags = {
    Environment = "Production"
    Project     = "IncumbentFI"
    ManagedBy   = "Terraform"
  }
}

# Add a resource lock to prevent deletion
resource "azurerm_management_lock" "resource_group_lock" {
  name       = "rg-lock"
  scope      = module.resource_group.resource_group_id
  lock_level = "CanNotDelete"
  notes      = "Prevent accidental deletion of production resource group"
}
```

### Using Outputs in Other Modules

```hcl
module "resource_group" {
  source   = "./modules/resource-group"
  
  name     = "rg-incumbentfi-prod-eastus-001"
  location = "East US"
  tags     = local.common_tags
}

# Use resource group output in another module
module "storage_account" {
  source = "./modules/storage-account"
  
  name                = "stincumbentfiprod001"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  tags                = module.resource_group.resource_group_tags
}
```

## Troubleshooting

### Common Issues

**Issue**: Resource group name already exists
- **Solution**: Choose a unique name or use Terraform import to manage existing resource group

**Issue**: Invalid location specified
- **Solution**: Use `az account list-locations -o table` to get valid locations

**Issue**: Tags not applied correctly
- **Solution**: Ensure tags variable is a map(string) type with valid key-value pairs

**Issue**: Permission denied when creating resource group
- **Solution**: Verify Azure credentials and ensure sufficient RBAC permissions (Contributor or Owner role)

### Getting Help

- Check [Azure Resource Manager documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/)
- Review [Terraform AzureRM provider issues](https://github.com/hashicorp/terraform-provider-azurerm/issues)
- Validate Azure subscription limits and quotas

## Module Maintenance

### Version History

- **v1.0.0** - Initial release with basic resource group creation
- Supports standard resource group properties
- Includes comprehensive tagging support
- Compatible with AzureRM provider v3.0+

### Contributing

When contributing to this module:
1. Run `terraform fmt` to format code
2. Run `terraform validate` to check syntax
3. Run security scans with Terrascan
4. Update documentation for any new variables or outputs
5. Test in a non-production environment first

## References

- [Azure Resource Groups Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview)
- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure Tagging Strategy](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure RBAC Documentation](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview)
- [Terrascan Documentation](https://runterrascan.io/docs/)
