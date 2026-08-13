# Azure Firewall Policy Module

This Terraform module creates an Azure Firewall Policy for centralized rule management across multiple Azure Firewalls using Azure Firewall Manager.

## Description

Azure Firewall Policy provides a centralized way to manage firewall rules, configuration, and policies across one or more Azure Firewalls or Firewall Manager resources. This module simplifies the creation of firewall policies with support for Standard and Premium SKUs, enabling consistent security policies organization-wide.

## Features

- ✅ Centralized firewall rule management
- ✅ Support for Standard and Premium SKUs
- ✅ Policy inheritance hierarchy
- ✅ Regional and global policy deployment
- ✅ Integration with Azure Firewall Manager
- ✅ Rule collection groups for organization
- ✅ Threat intelligence integration
- ✅ IDPS support (Premium tier)
- ✅ TLS inspection (Premium tier)
- ✅ Policy versioning and deployment
- ✅ Comprehensive tagging support

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
| `azurerm_firewall_policy` | The Azure Firewall Policy resource |

## Prerequisites

Before using this module, you should have:

1. **Resource Group** where the policy will be created
2. **Azure Subscription** with appropriate permissions
3. **Region** where the firewall policy will be deployed

## Usage

### Basic Firewall Policy (Standard SKU)

```hcl
module "firewall_policy" {
  source = "./modules/firewall-policy"
  
  name                = "fwpol-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  sku                 = "Standard"
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Premium Firewall Policy with Advanced Features

```hcl
module "firewall_policy_premium" {
  source = "./modules/firewall-policy"
  
  name                = "fwpol-premium-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  sku                 = "Premium"  # Advanced threat protection
  
  tags = {
    Environment = "Production"
    Tier        = "Premium"
    ManagedBy   = "Terraform"
  }
}
```

### Firewall Policy with Rule Collection

```hcl
# Create Firewall Policy
module "firewall_policy" {
  source = "./modules/firewall-policy"
  
  name                = "fwpol-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  sku                 = "Standard"
  
  tags = {
    Environment = "Production"
  }
}

# Create Rule Collection Group
resource "azurerm_firewall_policy_rule_collection_group" "example" {
  name               = "rcg-prod-eastus-001"
  firewall_policy_id = module.firewall_policy.firewall_policy_id
  priority           = 100

  nat_rule_collection {
    name     = "nat-rules"
    priority = 100
    action   = "Dnat"

    rule {
      name                = "translate-https"
      protocols           = ["TCP"]
      source_addresses    = ["*"]
      destination_address = azurerm_public_ip.fw_pip.ip_address
      destination_ports   = ["443"]
      translated_address  = "10.0.1.20"
      translated_port     = "443"
    }
  }

  network_rule_collection {
    name     = "network-rules"
    priority = 200
    action   = "Allow"

    rule {
      name                  = "allow-dns"
      source_addresses      = ["10.0.0.0/8"]
      destination_ports     = ["53"]
      destination_addresses = ["*"]
      protocols             = ["UDP"]
    }
  }

  application_rule_collection {
    name     = "application-rules"
    priority = 300
    action   = "Allow"

    rule {
      name             = "allow-microsoft"
      source_addresses = ["10.0.0.0/8"]
      destination_fqdns = ["*.microsoft.com", "*.azure.com"]
      protocols {
        type = "Https"
        port = 443
      }
    }
  }
}

output "firewall_policy_id" {
  value = module.firewall_policy.firewall_policy_id
}
```

### Complete Hub and Spoke with Firewall Manager

```hcl
locals {
  common_tags = {
    Environment = "Production"
    Project     = "IncumbentFI"
    ManagedBy   = "Terraform"
  }
}

# Resource Group for hub
module "hub_rg" {
  source = "./modules/resource-group"
  
  name     = "rg-hub-prod-eastus-001"
  location = "eastus"
  tags     = local.common_tags
}

# Firewall Policy (can be used by multiple firewalls)
module "firewall_policy" {
  source = "./modules/firewall-policy"
  
  name                = "fwpol-hub-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.hub_rg.resource_group_name
  sku                 = "Premium"
  
  tags = local.common_tags
}

# Firewall in hub
module "hub_firewall" {
  source = "./modules/firewall"
  
  name                = "fw-hub-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.hub_rg.resource_group_name
  
  sku_name = "AZFW_Hub"
  sku_tier = "Premium"
  
  ip_configuration_name   = "fw-ipconfig"
  subnet_id               = module.firewall_subnet.id
  public_ip_address_id    = azurerm_public_ip.fw_pip.id
  
  tags = local.common_tags
}

# Associate policy with firewall
resource "azurerm_firewall_policy_association" "hub_firewall_policy" {
  firewall_policy_id = module.firewall_policy.firewall_policy_id
  firewall_id        = module.hub_firewall.firewall_id
}

# Rule Collection Group
resource "azurerm_firewall_policy_rule_collection_group" "hub_rules" {
  name               = "rcg-hub-prod-eastus-001"
  firewall_policy_id = module.firewall_policy.firewall_policy_id
  priority           = 100

  network_rule_collection {
    name     = "default-allow"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "allow-internal"
      source_addresses      = ["10.0.0.0/8"]
      destination_ports     = ["*"]
      destination_addresses = ["10.0.0.0/8"]
      protocols             = ["TCP", "UDP"]
    }
  }

  application_rule_collection {
    name     = "default-web"
    priority = 200
    action   = "Allow"

    rule {
      name             = "allow-https"
      source_addresses = ["10.0.0.0/8"]
      destination_fqdns = ["*.azure.com", "*.microsoft.com"]
      protocols {
        type = "Https"
        port = 443
      }
    }
  }
}

output "firewall_policy_id" {
  value = module.firewall_policy.firewall_policy_id
}

output "firewall_id" {
  value = module.hub_firewall.firewall_id
}
```

### Spoke Firewall Policy (Inherits from Hub)

```hcl
# Resource Group for spoke
module "spoke_rg" {
  source = "./modules/resource-group"
  
  name     = "rg-spoke-prod-eastus-001"
  location = "eastus"
  tags     = local.common_tags
}

# Spoke Firewall Policy (inherits from hub policy)
module "spoke_firewall_policy" {
  source = "./modules/firewall-policy"
  
  name                = "fwpol-spoke-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.spoke_rg.resource_group_name
  sku                 = "Premium"
  
  tags = merge(local.common_tags, {
    Role = "Spoke"
  })
}

# Add spoke-specific rules
resource "azurerm_firewall_policy_rule_collection_group" "spoke_rules" {
  name               = "rcg-spoke-prod-eastus-001"
  firewall_policy_id = module.spoke_firewall_policy.firewall_policy_id
  priority           = 100

  application_rule_collection {
    name     = "spoke-services"
    priority = 100
    action   = "Allow"

    rule {
      name             = "allow-spoke-apps"
      source_addresses = ["10.0.0.0/8"]
      destination_fqdns = ["app.contoso.com", "api.contoso.com"]
      protocols {
        type = "Https"
        port = 443
      }
    }
  }
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | The name of the Firewall Policy | `string` | Yes | n/a |
| location | The Azure region for the policy | `string` | Yes | n/a |
| resource_group_name | The name of the resource group | `string` | Yes | n/a |
| sku | The SKU of the policy: Standard or Premium | `string` | Yes | n/a |
| tags | Tags to assign to the policy | `map(string)` | No | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| firewall_policy_id | The ID of the Azure Firewall Policy |
| firewall_policy_name | The name of the Azure Firewall Policy |

## SKU Comparison

### Standard SKU

**Tier Features:**
- ✅ Network rules (stateful filtering)
- ✅ Application rules (FQDN filtering)
- ✅ NAT rules (address translation)
- ✅ URL filtering (categorized URLs)
- ✅ Threat intelligence
- ✅ Multiple rule collection groups
- ❌ IDPS (Intrusion Detection/Prevention)
- ❌ TLS inspection
- ❌ Web categorization advanced
- ❌ Certificate-based user authentication

**Best for:** General network filtering and traffic management

**Cost:** Lower cost tier

### Premium SKU

**Tier Features:**
- ✅ All Standard features
- ✅ IDPS (Intrusion Detection/Prevention)
- ✅ TLS inspection (decrypt and inspect HTTPS)
- ✅ Advanced web categorization
- ✅ Certificate-based user authentication
- ✅ Geo-filtering
- ✅ URL filtering with custom categories
- ✅ Zero-trust network access

**Best for:** Enterprise with advanced security requirements

**Cost:** Higher cost but includes advanced threat protection

## Policy Structure

### Rule Collection Groups

Rules are organized in Rule Collection Groups with priorities:

```hcl
resource "azurerm_firewall_policy_rule_collection_group" "example" {
  name               = "rcg-prod-001"
  firewall_policy_id = module.firewall_policy.firewall_policy_id
  priority           = 100  # Lower number = higher priority

  # Rule collections inside this group
}
```

### Rule Collection Types

#### 1. NAT Rule Collection
Performs source/destination network address translation:

```hcl
nat_rule_collection {
  name     = "nat-rules"
  priority = 100
  action   = "Dnat"  # Destination NAT

  rule {
    name                = "translate-http"
    protocols           = ["TCP"]
    source_addresses    = ["*"]
    destination_address = "203.0.113.1"
    destination_ports   = ["80"]
    translated_address  = "10.0.1.20"
    translated_port     = "80"
  }
}
```

#### 2. Network Rule Collection
IP-based filtering (network layer):

```hcl
network_rule_collection {
  name     = "network-rules"
  priority = 200
  action   = "Allow"  # Allow or Deny

  rule {
    name                  = "allow-dns"
    source_addresses      = ["10.0.0.0/8"]
    destination_ports     = ["53"]
    destination_addresses = ["*"]
    protocols             = ["UDP", "TCP"]
  }
}
```

#### 3. Application Rule Collection
FQDN-based filtering (application layer):

```hcl
application_rule_collection {
  name     = "application-rules"
  priority = 300
  action   = "Allow"  # Allow or Deny

  rule {
    name             = "allow-azure"
    source_addresses = ["10.0.0.0/8"]
    destination_fqdns = ["*.azure.com", "*.microsoft.com"]
    protocols {
      type = "Https"  # Http, Https, Mssql
      port = 443
    }
  }
}
```

## Policy Hierarchy and Inheritance

Firewall Policies support a hierarchy:

```
Root Policy (Hub)
├── Parent Policy (Regional Hub)
│   ├── Child Policy 1 (Spoke 1)
│   ├── Child Policy 2 (Spoke 2)
│   └── Child Policy 3 (Spoke 3)
└── Parent Policy 2 (Regional Hub)
    └── Child Policy 4 (Spoke 4)
```

**Inheritance Features:**
- Child policies inherit rules from parent
- Child policies can override parent rules
- Rules are evaluated in priority order
- Network rules processed before application rules

## Policy Association

### Associate Policy with Firewall

```hcl
resource "azurerm_firewall_policy_association" "example" {
  firewall_policy_id = module.firewall_policy.firewall_policy_id
  firewall_id        = module.firewall.firewall_id
}
```

### One Policy, Multiple Firewalls

A single policy can be associated with multiple firewalls:

```hcl
resource "azurerm_firewall_policy_association" "fw1" {
  firewall_policy_id = module.firewall_policy.firewall_policy_id
  firewall_id        = azurerm_firewall.firewall1.id
}

resource "azurerm_firewall_policy_association" "fw2" {
  firewall_policy_id = module.firewall_policy.firewall_policy_id
  firewall_id        = azurerm_firewall.firewall2.id
}
```

## Rule Processing Order

Rules are evaluated in this order:

1. **NAT Rules** (highest priority in their priority level)
2. **Network Rules** (in priority order within their group)
3. **Application Rules** (in priority order within their group)

**Within each collection:**
- Rules evaluated in order of rule priority
- First matching rule determines the action (Allow/Deny)
- If no rule matches, default is Deny

## Threat Intelligence

### Enable Threat Intelligence

```hcl
resource "azurerm_firewall_policy_rule_collection_group" "example" {
  # ... configuration ...

  # Threat intelligence filtering
  # Blocks known malicious IPs and domains
}
```

### Threat Intelligence Modes

- **Off** - No threat intelligence filtering
- **Alert Only** - Log threats but allow traffic
- **Deny** - Block known malicious traffic

## Naming Conventions

Follow [Azure naming conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming):

- **Length**: 1-80 characters
- **Valid characters**: Alphanumerics, hyphens
- **Start with**: Alphanumeric
- **End with**: Alphanumeric
- **Recommended pattern**: `fwpol-<application>-<environment>-<region>-<instance>`

### Examples

- `fwpol-prod-eastus-001` - Production policy in East US
- `fwpol-hub-prod-eastus-001` - Hub policy in production
- `fwpol-spoke-prod-eastus-001` - Spoke policy in production
- `fwpol-premium-prod-eastus-001` - Premium tier policy

## Security Best Practices

1. **Use Premium Tier**: In production with advanced threat needs
2. **Centralize Rules**: Use parent policies for common rules
3. **Layered Rules**: Network rules before application rules
4. **Least Privilege**: Allow only necessary traffic
5. **Threat Intelligence**: Enable for production environments
6. **IDPS**: Enable IDPS (Premium) for intrusion detection
7. **Logging**: Enable diagnostics for all policies
8. **Rule Review**: Regularly audit and update rules
9. **Testing**: Test policy changes in non-prod first
10. **Versioning**: Version your policy configurations

## Policy Deployment Strategy

### Development Environment

```hcl
# Basic Standard policy for development
module "fw_policy_dev" {
  source = "./modules/firewall-policy"
  
  name                = "fwpol-dev-eastus-001"
  location            = "eastus"
  resource_group_name = module.rg_dev.resource_group_name
  sku                 = "Standard"  # Cost-effective
}
```

### Staging Environment

```hcl
# Premium policy mirroring production
module "fw_policy_staging" {
  source = "./modules/firewall-policy"
  
  name                = "fwpol-staging-eastus-001"
  location            = "eastus"
  resource_group_name = module.rg_staging.resource_group_name
  sku                 = "Premium"  # Same as prod
}
```

### Production Environment

```hcl
# Premium policy with advanced protections
module "fw_policy_prod" {
  source = "./modules/firewall-policy"
  
  name                = "fwpol-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.rg_prod.resource_group_name
  sku                 = "Premium"  # Advanced features
}
```

## Troubleshooting

### Common Issues

**Issue**: Policy creation fails with SKU error
- **Solution**:
  1. Verify SKU is either "Standard" or "Premium"
  2. Check region supports the selected SKU
  3. Ensure subscription has quota for the SKU tier

**Issue**: Rule association fails
- **Solution**:
  1. Verify firewall policy ID is correct
  2. Ensure firewall exists in the same region
  3. Check firewall and policy SKUs are compatible

**Issue**: Rules not being applied to firewall
- **Solution**:
  1. Verify policy is properly associated with firewall
  2. Check rule priorities and collection groups
  3. Ensure rules match the traffic criteria
  4. Review firewall logs for blocked traffic

**Issue**: Policy cannot be deleted
- **Solution**:
  1. Remove all policy associations first
  2. Delete all rule collection groups
  3. Then delete the policy

### Validation Commands

```powershell
# Show firewall policy details
az network firewall policy show --name fwpol-prod-eastus-001 \
  --resource-group rg-prod-001

# List policies in resource group
az network firewall policy list \
  --resource-group rg-prod-001 --output table

# Get policy SKU
az network firewall policy show --name fwpol-prod-eastus-001 \
  --resource-group rg-prod-001 --query "sku"

# Terraform validation
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
terrascan scan -d ./modules/firewall-policy -i terraform

# Lint check
tflint --init
tflint
```

## Notes

- **Policy Immutability**: SKU cannot be changed after creation; must recreate
- **Regional Deployment**: Policy and firewalls should be in same region
- **Rule Limits**: Maximum 10,000 rules per policy (usually sufficient)
- **Cost Implications**: Premium SKU has higher costs but includes advanced features
- **Deployment Time**: Policy creation is fast; rules may take longer
- **Compatibility**: Standard and Premium policies can coexist in same subscription
- **Inheritance**: Child policies inherit parent policy rules

## Module Maintenance

### Version History

- **v1.0.0** - Initial release
  - Firewall Policy creation
  - Support for Standard and Premium SKUs
  - Regional deployment
  - Tagging support

### Contributing

When contributing to this module:
1. Run `terraform fmt` to format code
2. Run `terraform validate` to check syntax
3. Test with both Standard and Premium SKUs
4. Test policy rule associations
5. Verify inheritance hierarchies
6. Run security scans with Terrascan or tfsec
7. Update documentation for any new variables or outputs

## References

- [Azure Firewall Policy Documentation](https://learn.microsoft.com/en-us/azure/firewall-manager/policy-overview)
- [Firewall Policy Rule Processing](https://learn.microsoft.com/en-us/azure/firewall/rule-processing)
- [Azure Firewall Manager](https://learn.microsoft.com/en-us/azure/firewall-manager/overview)
- [Rule Collection Groups](https://learn.microsoft.com/en-us/azure/firewall-manager/rule-groups)
- [Policy Inheritance](https://learn.microsoft.com/en-us/azure/firewall-manager/hierarchy)
- [Terraform AzureRM Firewall Policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy)
- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Best Practices for Firewall Policies](https://learn.microsoft.com/en-us/azure/firewall-manager/deployment-planning)
