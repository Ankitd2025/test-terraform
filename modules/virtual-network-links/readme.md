# Azure Private DNS Zone Virtual Network Link Module

This Terraform module creates and manages links between Azure Private DNS Zones and Virtual Networks, enabling private DNS name resolution within your virtual network infrastructure.

## Overview

Virtual network links establish the relationship between a Private DNS Zone and a Virtual Network. These links are essential for enabling DNS resolution of private DNS records within the virtual network. Without links, resources in a virtual network cannot resolve names in the private DNS zone.

This module simplifies the creation and management of these critical DNS infrastructure components.

## Features

- ✅ **Private DNS Zone to VNet Linking** - Connect virtual networks to private DNS zones
- ✅ **Centralized DNS Resolution** - Enable DNS name resolution across connected virtual networks
- ✅ **Multi-VNet Support** - Link multiple virtual networks to a single DNS zone
- ✅ **Tag Management** - Apply consistent tagging for resource governance
- ✅ **Flexible Configuration** - Easy-to-use variables for various scenarios
- ✅ **Reusable Module** - Create multiple links with a single module definition

## Prerequisites

- Azure subscription with appropriate permissions
- Existing Private DNS Zone
- Existing Virtual Network
- Both resources in the same subscription

## Usage

### Basic Virtual Network Link

```hcl
module "private_dns_zone_vnet_link" {
  source = "./modules/virtual-network-links"

  name                  = "link-vnet-to-pdz"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pdz.name
  virtual_network_id    = azurerm_virtual_network.vnet.id

  tags = local.common_tags
}
```

### Multiple Virtual Network Links

```hcl
locals {
  virtual_networks = {
    hub = {
      vnet_id = azurerm_virtual_network.hub_vnet.id
      name    = "hub"
    }
    spoke_1 = {
      vnet_id = azurerm_virtual_network.spoke1_vnet.id
      name    = "spoke1"
    }
    spoke_2 = {
      vnet_id = azurerm_virtual_network.spoke2_vnet.id
      name    = "spoke2"
    }
  }
}

module "private_dns_zone_vnet_links" {
  for_each = local.virtual_networks

  source = "./modules/virtual-network-links"

  name                  = "link-${each.value.name}-to-pdz"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pdz.name
  virtual_network_id    = each.value.vnet_id

  tags = merge(local.common_tags, {
    VNetName = each.value.name
  })
}
```

### Link Private DNS Zone to Hub and Spoke Networks

```hcl
# Private DNS Zone for Azure services
module "pdz_keyvault" {
  source = "./modules/private-dns-zone"

  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.common_tags
}

# Hub Virtual Network
module "hub_vnet" {
  source = "./modules/virtual-network"

  name                = "vnet-hub-prod-eastus-001"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

  tags = local.common_tags
}

# Spoke Virtual Networks
module "spoke1_vnet" {
  source = "./modules/virtual-network"

  name                = "vnet-spoke1-prod-eastus-001"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/16"]

  tags = local.common_tags
}

module "spoke2_vnet" {
  source = "./modules/virtual-network"

  name                = "vnet-spoke2-prod-eastus-001"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.2.0.0/16"]

  tags = local.common_tags
}

# Link all networks to the private DNS zone
module "link_hub_to_pdz" {
  source = "./modules/virtual-network-links"

  name                  = "link-hub-vnet-to-pdz"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = module.pdz_keyvault.name
  virtual_network_id    = module.hub_vnet.id

  tags = local.common_tags
}

module "link_spoke1_to_pdz" {
  source = "./modules/virtual-network-links"

  name                  = "link-spoke1-vnet-to-pdz"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = module.pdz_keyvault.name
  virtual_network_id    = module.spoke1_vnet.id

  tags = local.common_tags
}

module "link_spoke2_to_pdz" {
  source = "./modules/virtual-network-links"

  name                  = "link-spoke2-vnet-to-pdz"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = module.pdz_keyvault.name
  virtual_network_id    = module.spoke2_vnet.id

  tags = local.common_tags
}
```

### Multi-Service Private DNS with Shared VNet Links

```hcl
locals {
  private_dns_zones = {
    keyvault = "privatelink.vaultcore.azure.net"
    storage  = "privatelink.blob.core.windows.net"
    sql      = "privatelink.database.windows.net"
    acr      = "privatelink.azurecr.io"
  }
}

# Create all private DNS zones
module "private_dns_zones" {
  for_each = local.private_dns_zones

  source = "./modules/private-dns-zone"

  name                = each.value
  resource_group_name = azurerm_resource_group.rg.name

  tags = merge(local.common_tags, {
    Service = each.key
  })
}

# Link all zones to the virtual network
module "vnet_dns_links" {
  for_each = local.private_dns_zones

  source = "./modules/virtual-network-links"

  name                  = "link-vnet-to-${each.key}"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = module.private_dns_zones[each.key].name
  virtual_network_id    = azurerm_virtual_network.vnet.id

  tags = merge(local.common_tags, {
    Service = each.key
  })
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `name` | The name of the Private DNS Zone virtual network link | `string` | Yes | N/A |
| `resource_group_name` | Name of the resource group containing the private DNS zone | `string` | Yes | N/A |
| `private_dns_zone_name` | Name of the Private DNS Zone to link to | `string` | Yes | N/A |
| `virtual_network_id` | The resource ID of the virtual network to link | `string` | Yes | N/A |
| `tags` | Tags to assign to the virtual network link | `map(string)` | Yes | N/A |

## Outputs

This module does not produce outputs. The link resource is created but no specific attributes are exported.

## Common Use Cases

### 1. Hub and Spoke Network Topology

In a hub and spoke topology, a central private DNS zone is linked to the hub virtual network and all spoke networks:

```hcl
# All spokes share the same private DNS zone link
module "hub_spoke_dns_link" {
  for_each = {
    hub   = azurerm_virtual_network.hub.id
    spoke1 = azurerm_virtual_network.spoke1.id
    spoke2 = azurerm_virtual_network.spoke2.id
  }

  source = "./modules/virtual-network-links"

  name                  = "link-${each.key}-to-central-dns"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.central.name
  virtual_network_id    = each.value

  tags = local.common_tags
}
```

### 2. Multi-Region DNS Resolution

Link virtual networks in different regions to a centrally managed private DNS zone:

```hcl
module "multi_region_dns_links" {
  for_each = {
    eastus = {
      vnet_id = azurerm_virtual_network.eastus.id
      region  = "eastus"
    }
    westus = {
      vnet_id = azurerm_virtual_network.westus.id
      region  = "westus"
    }
  }

  source = "./modules/virtual-network-links"

  name                  = "link-vnet-${each.value.region}-to-dns"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.global.name
  virtual_network_id    = each.value.vnet_id

  tags = merge(local.common_tags, {
    Region = each.value.region
  })
}
```

### 3. Azure PaaS Private Link Services

Link virtual networks to private DNS zones for various Azure PaaS services:

```hcl
locals {
  azure_services = {
    keyvault = {
      dns_zone = "privatelink.vaultcore.azure.net"
      zone_id  = module.pdz_keyvault.id
    }
    storage = {
      dns_zone = "privatelink.blob.core.windows.net"
      zone_id  = module.pdz_storage.id
    }
    sql = {
      dns_zone = "privatelink.database.windows.net"
      zone_id  = module.pdz_sql.id
    }
    appservice = {
      dns_zone = "privatelink.azurewebsites.net"
      zone_id  = module.pdz_appservice.id
    }
  }
}

module "paas_dns_links" {
  for_each = local.azure_services

  source = "./modules/virtual-network-links"

  name                  = "link-vnet-to-${each.key}-dns"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = each.value.dns_zone
  virtual_network_id    = azurerm_virtual_network.vnet.id

  tags = merge(local.common_tags, {
    Service = each.key
  })
}
```

## Network Topology Examples

### Simple VNet to Private DNS Zone

```
Private DNS Zone
├─ privatelink.vaultcore.azure.net
│
└─ Link to VNet
   └─ vnet-prod-eastus
      ├─ Subnet-1 (Resources can resolve DNS names)
      ├─ Subnet-2 (Resources can resolve DNS names)
      └─ Subnet-3 (Resources can resolve DNS names)
```

### Hub and Spoke with Shared DNS

```
Private DNS Zone
├─ privatelink.vaultcore.azure.net
│
├─ Link to Hub VNet
│  └─ vnet-hub-prod-eastus
│
├─ Link to Spoke 1 VNet
│  └─ vnet-spoke1-prod-eastus
│
└─ Link to Spoke 2 VNet
   └─ vnet-spoke2-prod-eastus

(All networks can resolve names in the private DNS zone)
```

### Multi-Service Private DNS Setup

```
Virtual Network
└─ vnet-prod-eastus

├─ Link to privatelink.vaultcore.azure.net
├─ Link to privatelink.blob.core.windows.net
├─ Link to privatelink.database.windows.net
├─ Link to privatelink.azurecr.io
└─ Link to privatelink.servicebus.windows.net

(All services are privately accessible)
```

## DNS Resolution Flow

When a resource in a linked virtual network attempts to resolve a DNS name:

1. **Query Initiated** - Resource queries DNS name (e.g., `keyvault.vault.azure.com`)
2. **Private DNS Check** - Azure DNS resolver checks if name matches private DNS zone
3. **Zone Match** - If name matches a linked private DNS zone, resolution uses private records
4. **Private IP Resolution** - Returns the private IP address of the private endpoint
5. **Secure Connection** - Resource connects to service via private endpoint without internet exposure

## Best Practices

### Planning & Design
1. **Central DNS Zones**: Create private DNS zones at the subscription or management group level
2. **Consistent Naming**: Use descriptive names like `link-{vnet-name}-to-{service-name}`
3. **Resource Grouping**: Place links in the same resource group as the private DNS zone
4. **Tagging Strategy**: Tag links with service information and environment

### Network Design
1. **Hub and Spoke**: Link all networks to centralized private DNS zones
2. **Multi-Region**: Use global private DNS zones linked across regions
3. **Service Organization**: Create separate DNS zones for different service categories
4. **Name Resolution**: Ensure all required networks are linked before deploying private endpoints

### Operations
1. **Link Verification**: Regularly verify all required networks are linked
2. **Testing**: Test DNS resolution from resources in each linked network
3. **Documentation**: Document which networks are linked to which DNS zones
4. **Monitoring**: Monitor DNS resolution failures and connectivity issues

## Troubleshooting

### Issue: DNS Resolution Fails

**Symptoms**: Cannot resolve private DNS names from resources in the VNet

**Possible Causes:**
- Virtual network link not created
- Link using wrong virtual network ID
- Private DNS zone name incorrect
- Firewall blocking DNS traffic

**Solutions:**
```bash
# Verify the link exists
az network private-dns link vnet list \
  --resource-group <rg> \
  --zone-name <zone-name>

# Test DNS resolution from a VM in the VNet
nslookup keyvault.vaultcore.azure.net

# Verify private endpoint is configured
az network private-endpoint list --resource-group <rg>
```

### Issue: Multiple VNet Links Failing

**Possible Causes:**
- Incorrect private DNS zone name
- Resource group mismatch
- Permissions issue
- Network connectivity issue

**Solutions:**
1. Verify private DNS zone exists: `az network private-dns zone list --resource-group <rg>`
2. Verify virtual network exists: `az network vnet list --resource-group <rg>`
3. Check RBAC permissions on both resources
4. Validate network connectivity between resources

### Issue: Private Endpoint Not Accessible

**Possible Causes:**
- Virtual network link not configured
- Network security group rules blocking traffic
- Private endpoint not properly configured

**Solutions:**
```bash
# Verify link exists
az network private-dns link vnet show \
  --resource-group <rg> \
  --zone-name <zone-name> \
  --name <link-name>

# Test connectivity
Test-NetConnection -ComputerName <endpoint-ip> -Port 443

# Verify NSG rules
az network nsg rule list \
  --resource-group <rg> \
  --nsg-name <nsg-name>
```

## Integration with Other Modules

### Private Endpoints Module
```hcl
# Create private endpoint
module "private_endpoint" {
  source = "./modules/private-endpoints"
  # ... configuration
}

# Link VNet to the DNS zone required by the private endpoint
module "vnet_link" {
  source = "./modules/virtual-network-links"

  name                  = "link-vnet-to-keyvault-dns"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = azurerm_virtual_network.vnet.id

  tags = local.common_tags

  depends_on = [module.private_endpoint]
}
```

### Multiple VNet Management
```hcl
# Link multiple virtual networks to a single DNS zone
module "vnet_links" {
  for_each = var.virtual_networks

  source = "./modules/virtual-network-links"

  name                  = "link-${each.key}-to-dns"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.shared.name
  virtual_network_id    = each.value.vnet_id

  tags = local.common_tags
}
```

## Related Modules

- [Private DNS Zone](../private-dns-zone/readme.md) - Create the DNS zones to link
- [Virtual Network](../virtual-network/readme.md) - Create virtual networks to link
- [Private Endpoints](../private-endpoints/readme.md) - Leverage linked DNS zones for private endpoints
- [Subnet](../subnet/readme.md) - Resources in subnets will use the linked DNS

## Additional Resources

- [Azure Private DNS Documentation](https://learn.microsoft.com/en-us/azure/dns/private-dns-overview)
- [Virtual Network Link Documentation](https://learn.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links)
- [Private Link Documentation](https://learn.microsoft.com/en-us/azure/private-link/)
- [Azure DNS Best Practices](https://learn.microsoft.com/en-us/azure/dns/best-practices-dns)

## Notes

- Each virtual network can be linked to multiple private DNS zones
- Each private DNS zone can have links from multiple virtual networks
- Links are regional and scoped to the virtual network
- DNS name resolution uses the linked private DNS zone's records
- Link creation is instant and takes effect immediately
- Deleting a link removes DNS resolution for that zone from the virtual network
