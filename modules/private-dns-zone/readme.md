# Azure Private DNS Zone Module

This Terraform module creates and manages an Azure Private DNS Zone for private domain name resolution within virtual networks.

## Overview

The Private DNS Zone module provisions a private DNS zone in Azure that enables custom domain name resolution for resources within your virtual networks. Private DNS zones are ideal for:
- Internal application DNS resolution
- Private endpoints and services
- Hybrid cloud scenarios with on-premises connectivity
- Multi-tier application architectures
- Isolating DNS resolution from the public internet

## Usage

### Basic Example

```hcl
module "private_dns_zone" {
  source = "./modules/private-dns-zone"

  name                = "internal.example.com"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
}
```

### With Multiple Zones

```hcl
module "private_dns_zone_primary" {
  source = "./modules/private-dns-zone"

  name                = "app.internal.example.com"
  resource_group_name = azurerm_resource_group.rg.name
  tags = merge(
    local.common_tags,
    {
      Purpose = "Primary Application DNS"
    }
  )
}

module "private_dns_zone_secondary" {
  source = "./modules/private-dns-zone"

  name                = "data.internal.example.com"
  resource_group_name = azurerm_resource_group.rg.name
  tags = merge(
    local.common_tags,
    {
      Purpose = "Data Layer DNS"
    }
  )
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the Private DNS Zone | `string` | N/A | Yes |
| `resource_group_name` | Name of the resource group | `string` | N/A | Yes |
| `tags` | Tags to assign to the Private DNS Zone | `map(string)` | N/A | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `azurerm_private_dns_zone_id` | The ID of the Private DNS Zone |
| `azurerm_private_dns_zone_name` | The name of the Private DNS Zone |

## Features

### DNS Resolution
- **Private Resolution**: Custom domain name resolution within virtual networks
- **Hybrid Connectivity**: Supports DNS resolution for hybrid cloud and on-premises scenarios
- **Isolated Namespace**: Complete isolation from public DNS infrastructure

### Integration Points
- Links to virtual networks for DNS resolution
- Compatible with private endpoints for Azure services
- Supports custom A, CNAME, MX, and other DNS records

## Best Practices

1. **Naming Convention**: Use descriptive, hierarchical names (e.g., `internal.example.com`, `app.example.com`)
2. **Consistency**: Use consistent naming patterns across multiple zones in your organization
3. **Virtual Network Links**: Ensure virtual networks are properly linked to the private DNS zone for resolution to work
4. **DNS Records**: Create appropriate DNS records (A, CNAME, MX, SRV, TXT) for your applications
5. **Resource Organization**: Group related zones in the same resource group
6. **Tagging**: Apply comprehensive tags for better resource management and cost tracking
7. **Documentation**: Document the purpose of each zone and the services it supports

## Common Use Cases

### Azure PaaS Services
Link private DNS zones to private endpoints for Azure services:
- `privatelink.database.windows.net` for SQL Database
- `privatelink.blob.core.windows.net` for Storage Accounts
- `privatelink.vaultcore.azure.net` for Key Vault

### Application Services
Create zones for internal application domains:
- `app.internal.company.com` for web applications
- `api.internal.company.com` for API services
- `db.internal.company.com` for database connections

### Hybrid Scenarios
Support DNS resolution across on-premises and cloud environments:
- Conditional forwarding rules for on-premises domains
- Split-horizon DNS for dual environments

## Notes

- Private DNS zone names must be valid domain names
- Virtual networks must be explicitly linked to the Private DNS Zone for resolution to work
- Multiple virtual networks can be linked to the same zone
- Private DNS zones do not support zone transfers or AXFR
- Ensure proper RBAC permissions are assigned for users managing DNS zones
- When creating zones for Azure private endpoints, use Microsoft-managed namespaces (e.g., `privatelink.*`)

## Linking to Virtual Networks

To make the zone functional, link it to virtual networks:

```hcl
resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "link-vnet-${azurerm_virtual_network.vnet.name}"
  private_dns_zone_id   = module.private_dns_zone.azurerm_private_dns_zone_id
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}
```

## Related Modules

- [Virtual Network](../virtual-network/readme.md) - For VNet infrastructure
- [Resource Group](../resource-group/readme.md) - For resource organization
- [Subnet](../subnet/readme.md) - For subnet configurations
