# Azure Subnet Module

This Terraform module creates an Azure Subnet within a Virtual Network with automatic Network Security Group (NSG) provisioning and association, along with support for service endpoints, private endpoint policies, and subnet delegation.

## Description

Azure Subnets are logical segments within a Virtual Network that enable you to organize and secure your resources. This module simplifies subnet creation by automatically provisioning and associating Network Security Groups, while intelligently handling special Azure-reserved subnets that don't require NSGs.

> **Note**: Azure subnets do not support tags. The `tags` variable in this module applies only to the automatically created Network Security Group (NSG), not to the subnet itself.

## Features

- ✅ Subnet creation within existing Virtual Networks
- ✅ **Automatic NSG creation and association** for standard subnets
- ✅ **Intelligent NSG handling** - automatically skips NSG for special Azure subnets:
  - `GatewaySubnet` (for VPN/ExpressRoute gateways)
  - `AzureFirewallSubnet` (for Azure Firewall)
  - `AzureBastionSubnet` (for Azure Bastion)
- ✅ Service endpoint support for Azure PaaS services
- ✅ Private endpoint network policies configuration
- ✅ Subnet delegation for specialized Azure services
- ✅ **Diagnostic logging** - Optional monitoring of NSG audit logs
- ✅ Tagging support for automatically created NSGs
- ✅ Standardized naming convention for NSGs

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

| Resource Type | Description | Conditional |
|--------------|-------------|-------------|
| `azurerm_subnet` | The subnet resource | Always |
| `azurerm_network_security_group` | Network Security Group | Yes - Only for standard subnets* |
| `azurerm_subnet_network_security_group_association` | NSG association with subnet | Yes - Only for standard subnets* |
| `azurerm_monitor_diagnostic_setting` | Diagnostic logging for NSG | Yes - Only when diagnostics enabled AND NSG created** |

\* NSG is **not** created for: `GatewaySubnet`, `AzureFirewallSubnet`, `AzureBastionSubnet`
\** Diagnostic settings are only created when BOTH `enable_diagnostic = true` AND NSG is created

## Usage

### Basic Subnet

```hcl
module "subnet" {
  source = "./modules/subnet"
  
  name                              = "snet-web-prod-eastus-001"
  resource_group_name               = "rg-incumbentfi-prod-eastus-001"
  virtual_network_name              = "vnet-incumbentfi-prod-eastus-001"
  address_prefixes                  = ["10.0.1.0/24"]
  location                          = "eastus"
  private_endpoint_network_policies = "Enabled"
  
  tags = {
    Environment = "Production"
    Tier        = "Web"
    ManagedBy   = "Terraform"
  }  # Tags apply to the auto-created NSG only
}
```

### Subnet with Service Endpoints

```hcl
module "subnet_data" {
  source = "./modules/subnet"
  
  name                              = "snet-data-prod-eastus-001"
  resource_group_name               = module.resource_group.resource_group_name
  virtual_network_name              = module.virtual_network.name
  address_prefixes                  = ["10.0.2.0/24"]
  location                          = "eastus"
  private_endpoint_network_policies = "Enabled"
  enable_diagnostic                 = false
  
  service_endpoints = [
    "Microsoft.Sql",
    "Microsoft.Storage",
    "Microsoft.KeyVault"
  ]
  
  tags = {
    Environment = "Production"
    Tier        = "Data"
    ManagedBy   = "Terraform"
  }
}
```

### Subnet with Diagnostic Logging

```hcl
module "subnet_monitored" {
  source = "./modules/subnet"
  
  name                              = "snet-app-prod-eastus-001"
  resource_group_name               = module.resource_group.resource_group_name
  virtual_network_name              = module.virtual_network.name
  address_prefixes                  = ["10.0.2.0/24"]
  location                          = "eastus"
  private_endpoint_network_policies = "Enabled"
  enable_diagnostic                 = true
  log_analytics_workspace_id        = module.log_analytics_workspace.id
  
  service_endpoints = [
    "Microsoft.Sql",
    "Microsoft.Storage"
  ]
  
  tags = {
    Environment = "Production"
    Tier        = "Application"
    ManagedBy   = "Terraform"
  }  # Tags apply to the auto-created NSG only
}
```

### Subnet with Delegation (Azure SQL Managed Instance)

```hcl
module "subnet_sqlmi" {
  source = "./modules/subnet"
  
  name                              = "snet-sqlmi-prod-eastus-001"
  resource_group_name               = module.resource_group.resource_group_name
  virtual_network_name              = module.virtual_network.name
  address_prefixes                  = ["10.0.3.0/24"]
  location                          = "eastus"
  private_endpoint_network_policies = "Disabled"
  
  delegation_name         = "sqlmi-delegation"
  delegation_service_name = "Microsoft.Sql/managedInstances"
  delegation_actions = [
    "Microsoft.Network/virtualNetworks/subnets/join/action",
    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
    "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
  ]
  
  tags = {
    Environment = "Production"
    Service     = "SQL-MI"
    ManagedBy   = "Terraform"
  }  # Tags apply to the auto-created NSG only
}
```

### Special Azure Subnets (No NSG)

```hcl
# Gateway Subnet - NSG automatically skipped
module "gateway_subnet" {
  source = "./modules/subnet"
  
  name                              = "GatewaySubnet"
  resource_group_name               = module.resource_group.resource_group_name
  virtual_network_name              = module.virtual_network.name
  address_prefixes                  = ["10.0.255.0/27"]
  location                          = "eastus"
  private_endpoint_network_policies = "Enabled"
  
  tags = {
    Environment = "Production"
    Purpose     = "VPN-Gateway"
    ManagedBy   = "Terraform"
  }  # No NSG created for GatewaySubnet, tags ignored
}

# Azure Firewall Subnet - NSG automatically skipped
module "firewall_subnet" {
  source = "./modules/subnet"
  
  name                              = "AzureFirewallSubnet"
  resource_group_name               = module.resource_group.resource_group_name
  virtual_network_name              = module.virtual_network.name
  address_prefixes                  = ["10.0.254.0/26"]
  location                          = "eastus"
  private_endpoint_network_policies = "Enabled"
  
  tags = {
    Environment = "Production"
    Purpose     = "Firewall"
    ManagedBy   = "Terraform"
  }  # No NSG created for AzureFirewallSubnet, tags ignored
}

# Azure Bastion Subnet - NSG automatically skipped
module "bastion_subnet" {
  source = "./modules/subnet"
  
  name                              = "AzureBastionSubnet"
  resource_group_name               = module.resource_group.resource_group_name
  virtual_network_name              = module.virtual_network.name
  address_prefixes                  = ["10.0.253.0/27"]
  location                          = "eastus"
  private_endpoint_network_policies = "Enabled"
  
  tags = {
    Environment = "Production"
    Purpose     = "Bastion"
    ManagedBy   = "Terraform"
  }  # No NSG created for AzureBastionSubnet, tags ignored
}
```

### Complete Multi-Tier Architecture

```hcl
locals {
  common_tags = {
    Environment = "Production"
    Project     = "IncumbentFI"
    ManagedBy   = "Terraform"
  }
}

# Web Tier Subnet
module "subnet_web" {
  source = "./modules/subnet"
  
  name                              = "snet-web-prod-eastus-001"
  resource_group_name               = module.resource_group.resource_group_name
  virtual_network_name              = module.virtual_network.name
  address_prefixes                  = ["10.0.1.0/24"]
  location                          = "eastus"
  private_endpoint_network_policies = "Enabled"
  
  service_endpoints = [
    "Microsoft.Web",
    "Microsoft.KeyVault"
  ]
  
  tags = merge(local.common_tags, {
    Tier = "Web"
  })
}

# Application Tier Subnet
module "subnet_app" {
  source = "./modules/subnet"
  
  name                              = "snet-app-prod-eastus-001"
  resource_group_name               = module.resource_group.resource_group_name
  virtual_network_name              = module.virtual_network.name
  address_prefixes                  = ["10.0.2.0/24"]
  location                          = "eastus"
  private_endpoint_network_policies = "Enabled"
  
  service_endpoints = [
    "Microsoft.Sql",
    "Microsoft.Storage",
    "Microsoft.KeyVault"
  ]
  
  tags = merge(local.common_tags, {
    Tier = "Application"
  })
}

# Data Tier Subnet
module "subnet_data" {
  source = "./modules/subnet"
  
  name                              = "snet-data-prod-eastus-001"
  resource_group_name               = module.resource_group.resource_group_name
  virtual_network_name              = module.virtual_network.name
  address_prefixes                  = ["10.0.3.0/24"]
  location                          = "eastus"
  private_endpoint_network_policies = "Disabled"
  
  service_endpoints = [
    "Microsoft.Sql",
    "Microsoft.Storage"
  ]
  
  tags = merge(local.common_tags, {
    Tier = "Data"
  })
}

# Private Endpoints Subnet
module "subnet_private_endpoints" {
  source = "./modules/subnet"
  
  name                              = "snet-pe-prod-eastus-001"
  resource_group_name               = module.resource_group.resource_group_name
  virtual_network_name              = module.virtual_network.name
  address_prefixes                  = ["10.0.4.0/24"]
  location                          = "eastus"
  private_endpoint_network_policies = "Disabled"
  
  tags = merge(local.common_tags, {
    Purpose = "PrivateEndpoints"
  })
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | The name of the subnet | `string` | Yes | n/a |
| resource_group_name | The name of the resource group containing the virtual network | `string` | Yes | n/a |
| virtual_network_name | The name of the virtual network where the subnet will be created | `string` | Yes | n/a |
| address_prefixes | The address prefixes to use for the subnet (CIDR notation) | `list(string)` | Yes | n/a |
| location | The Azure region where the NSG will be created | `string` | Yes | n/a |
| private_endpoint_network_policies | Enable or Disable network policies for private endpoints. Valid values: `Enabled`, `Disabled`, `NetworkSecurityGroupEnabled`, `RouteTableEnabled` | `string` | Yes | n/a |
| enable_diagnostic | Enable diagnostic logging for the Network Security Group | `bool` | Yes | n/a |
| log_analytics_workspace_id | The resource ID of the Log Analytics Workspace for diagnostics (required if `enable_diagnostic = true`) | `string` | Conditional | n/a |
| service_endpoints | List of service endpoints to enable on the subnet | `list(string)` | No | `[]` |
| delegation_name | The name of the delegation (required if delegating the subnet) | `string` | No | `null` |
| delegation_service_name | The service to which the subnet will be delegated | `string` | No | `null` |
| delegation_actions | List of actions permitted for the delegation | `list(string)` | No | `[]` |
| tags | A map of tags to assign to the auto-created NSG (not applied to subnet itself as Azure subnets don't support tags) | `map(string)` | No | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the subnet |
| name | The name of the subnet |

## Azure Naming Conventions

When naming subnets, follow [Azure naming conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming):

- **Length**: 1-80 characters
- **Valid characters**: Alphanumerics, underscores, periods, and hyphens
- **Start with**: Alphanumeric
- **End with**: Alphanumeric or underscore
- **Recommended pattern**: `snet-<workload>-<environment>-<region>-<instance>`

### Naming Examples

**Standard Subnets:**
- `snet-web-prod-eastus-001` (Web tier)
- `snet-app-prod-eastus-001` (Application tier)
- `snet-data-prod-eastus-001` (Data tier)
- `snet-pe-prod-eastus-001` (Private endpoints)
- `snet-aks-prod-eastus-001` (AKS nodes)

**Special Azure Subnets (Fixed Names):**
- `GatewaySubnet` (VPN/ExpressRoute - must be exact name)
- `AzureFirewallSubnet` (Azure Firewall - must be exact name)
- `AzureBastionSubnet` (Azure Bastion - must be exact name)

## Subnet Planning Best Practices

### Address Space Planning

1. **Size appropriately**: Plan subnet size based on expected workload
   - Small workloads: /27 (32 addresses, 27 usable)
   - Medium workloads: /24 (256 addresses, 251 usable)
   - Large workloads: /22 (1024 addresses, 1019 usable)
   - AKS clusters: /22 or larger depending on scale

2. **Azure reserved addresses**: Azure reserves 5 IP addresses in each subnet:
   - `.0` - Network address
   - `.1` - Default gateway
   - `.2`, `.3` - Azure DNS
   - `.255` - Broadcast address (in a /24)

3. **Leave room for growth**: Don't allocate all available space immediately

### Subnet Segmentation Strategy

```hcl
# Example VNet: 10.0.0.0/16 (65,536 addresses)

# Management tier - 10.0.0.0/24 (256 addresses)
# Web tier       - 10.0.1.0/24 (256 addresses)
# App tier       - 10.0.2.0/24 (256 addresses)
# Data tier      - 10.0.3.0/24 (256 addresses)
# Private Endpoints - 10.0.4.0/24 (256 addresses)
# AKS tier       - 10.0.8.0/22 (1024 addresses)
# Azure Services - 10.0.253.0/24 (Bastion, Firewall, Gateway)
```

## Service Endpoints

Service endpoints enable direct connectivity from your subnet to Azure PaaS services over the Azure backbone network.

### Available Service Endpoints

| Service Endpoint | Description |
|-----------------|-------------|
| `Microsoft.Storage` | Azure Storage (Blob, File, Queue, Table) |
| `Microsoft.Sql` | Azure SQL Database, SQL Managed Instance |
| `Microsoft.AzureCosmosDB` | Azure Cosmos DB |
| `Microsoft.KeyVault` | Azure Key Vault |
| `Microsoft.ServiceBus` | Azure Service Bus |
| `Microsoft.EventHub` | Azure Event Hubs |
| `Microsoft.Web` | Azure App Service, Function Apps |
| `Microsoft.ContainerRegistry` | Azure Container Registry |
| `Microsoft.CognitiveServices` | Azure Cognitive Services |

### Benefits

- ✅ Improved security (traffic stays on Azure backbone)
- ✅ Optimal routing and performance
- ✅ Free (no additional cost)
- ✅ Simple setup (no additional infrastructure)

### When to Use Service Endpoints vs Private Endpoints

**Service Endpoints:**
- Cost-effective solution
- Don't require additional IP addresses
- Traffic still uses public IP of PaaS service
- Secured via firewall rules

**Private Endpoints:**
- Provide private IP address for PaaS service
- Complete private connectivity
- Require subnet IP addresses
- Better for strict security requirements
- Use with `private_endpoint_network_policies = "Disabled"`

## Private Endpoint Network Policies

Controls network policies for private endpoints in the subnet.

### Valid Values

| Value | Description |
|-------|-------------|
| `Enabled` | Network policies (NSG, UDR) apply to private endpoints |
| `Disabled` | Network policies **do not** apply to private endpoints (legacy behavior) |
| `NetworkSecurityGroupEnabled` | Only NSG rules apply to private endpoints |
| `RouteTableEnabled` | Only UDR (User Defined Routes) apply to private endpoints |

### Recommendations

- Use `"Disabled"` for subnets dedicated to private endpoints
- Use `"Enabled"` for standard workload subnets
- Use specific options (`NetworkSecurityGroupEnabled`, `RouteTableEnabled`) when you need granular control

## Subnet Delegation

Subnet delegation allows Azure services to inject service-specific resources into your subnet.

### Common Delegation Scenarios

#### Azure SQL Managed Instance

```hcl
delegation_name         = "sqlmi-delegation"
delegation_service_name = "Microsoft.Sql/managedInstances"
delegation_actions = [
  "Microsoft.Network/virtualNetworks/subnets/join/action",
  "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
  "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
]
```

#### Azure Container Instances

```hcl
delegation_name         = "aci-delegation"
delegation_service_name = "Microsoft.ContainerInstance/containerGroups"
delegation_actions = [
  "Microsoft.Network/virtualNetworks/subnets/action"
]
```

#### Azure App Service (VNet Integration)

```hcl
delegation_name         = "appservice-delegation"
delegation_service_name = "Microsoft.Web/serverFarms"
delegation_actions = [
  "Microsoft.Network/virtualNetworks/subnets/action"
]
```

#### Azure Databricks

```hcl
delegation_name         = "databricks-delegation"
delegation_service_name = "Microsoft.Databricks/workspaces"
delegation_actions = [
  "Microsoft.Network/virtualNetworks/subnets/join/action",
  "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
  "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
]
```

#### Azure NetApp Files

```hcl
delegation_name         = "netapp-delegation"
delegation_service_name = "Microsoft.Netapp/volumes"
delegation_actions = [
  "Microsoft.Network/networkinterfaces/*",
  "Microsoft.Network/virtualNetworks/subnets/join/action"
]
```

## Network Security Groups (NSG)

### Automatic NSG Creation

This module **automatically creates and associates** a Network Security Group with the subnet, following these rules:

> **Important**: Azure subnets themselves do not support tags. Tags provided to this module are applied only to the automatically created NSG resource.

✅ **NSG is created for:**
- All standard subnets
- Workload subnets (web, app, data)
- AKS subnets
- Any custom-named subnet

❌ **NSG is NOT created for:**
- `GatewaySubnet` (VPN/ExpressRoute Gateway requirement)
- `AzureFirewallSubnet` (Azure Firewall requirement)
- `AzureBastionSubnet` (Azure Bastion requirement)

### NSG Naming Convention

The module automatically generates NSG names using the pattern:
```
nsg-<subnet-name>
```

**Examples:**
- Subnet: `snet-web-prod-eastus-001` → NSG: `nsg-snet-web-prod-eastus-001`
- Subnet: `snet-app-prod-eastus-001` → NSG: `nsg-snet-app-prod-eastus-001`

### Adding NSG Rules

NSG rules must be added separately after the subnet is created:

```hcl
# Create subnet with automatic NSG
module "subnet_web" {
  source = "./modules/subnet"
  
  name                              = "snet-web-prod-eastus-001"
  resource_group_name               = module.resource_group.resource_group_name
  virtual_network_name              = module.virtual_network.name
  address_prefixes                  = ["10.0.1.0/24"]
  location                          = "eastus"
  private_endpoint_network_policies = "Enabled"
  
  tags = local.common_tags
}

# Add NSG security rules
resource "azurerm_network_security_rule" "allow_https" {
  name                        = "AllowHTTPS"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "10.0.1.0/24"
  resource_group_name         = module.resource_group.resource_group_name
  network_security_group_name = "nsg-snet-web-prod-eastus-001"
  
  depends_on = [module.subnet_web]
}

resource "azurerm_network_security_rule" "allow_http" {
  name                        = "AllowHTTP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "10.0.1.0/24"
  resource_group_name         = module.resource_group.resource_group_name
  network_security_group_name = "nsg-snet-web-prod-eastus-001"
  
  depends_on = [module.subnet_web]
}
```

## Diagnostic Logging

### Overview

This module supports optional diagnostic logging for the automatically created Network Security Group. Diagnostic logs capture audit information and can be sent to a Log Analytics workspace for analysis and monitoring.

### When Diagnostics Are Created

Diagnostic settings are created **only when BOTH conditions are met:**
1. ✅ `enable_diagnostic = true`
2. ✅ **AND** an NSG is created for the subnet (i.e., not a restricted subnet)

**Important**: Diagnostics are **NOT** created for restricted subnets (`GatewaySubnet`, `AzureFirewallSubnet`, `AzureBastionSubnet`) even if enabled, because no NSG exists for these subnets.

### Enabling Diagnostics

```hcl
module "subnet_monitored" {
  source = "./modules/subnet"
  
  name                           = "snet-app-prod-eastus-001"
  resource_group_name            = module.resource_group.resource_group_name
  virtual_network_name           = module.virtual_network.name
  address_prefixes               = ["10.0.2.0/24"]
  location                       = "eastus"
  private_endpoint_network_policies = "Enabled"
  enable_diagnostic              = true
  log_analytics_workspace_id     = module.log_analytics_workspace.id
  
  tags = local.common_tags
}
```

### Log Categories Captured

When diagnostic logging is enabled, the following categories are captured:
- **Audit Logs** (`audit`) - NSG activity and changes
- **All Logs** (`allLogs`) - Complete audit trail

### Best Practices for Diagnostics

1. **Enable for Production**: Always enable diagnostics for production subnets
2. **Centralized Logging**: Send logs to a centralized Log Analytics workspace
3. **Retention Policy**: Set appropriate retention periods on the Log Analytics workspace
4. **Query Logs**: Use KQL queries to analyze NSG activity
5. **Alerts**: Set up alerts for suspicious NSG activity
6. **Restricted Subnets**: Be aware that restricted subnets won't have diagnostic settings

### Querying NSG Logs

```kusto
// Example KQL query to find denied connections
AzureDiagnostics
| where ResourceType == "NETWORKSECURITYGROUPS"
| where OperationName == "NetworkSecurityGroupFlowEvent"
| where FlowStatus_s == "D"  // Denied
| summarize Count = count() by SourceIP, DestinationIP, DestinationPort_d
| sort by Count desc
```

## Security Best Practices

1. **Network Segmentation**: Use separate subnets for each tier (web, app, data)
2. **NSG Rules**: Define least-privilege NSG rules after subnet creation
3. **Service Endpoints**: Use service endpoints to secure PaaS services
4. **Private Endpoints**: Use private endpoints for PaaS services requiring private IP addresses
5. **Subnet Delegation**: Only delegate subnets when required by specific Azure services
6. **Address Planning**: Plan address space carefully to avoid overlaps
7. **Diagnostic Logging**: Enable diagnostic logging in production to monitor NSG activity
8. **Log Retention**: Maintain appropriate retention policies for compliance and cost optimization
9. **Monitoring**: Enable NSG flow logs for security monitoring and troubleshooting
10. **Application Security Groups**: Use ASGs for fine-grained security rules

## Special Subnet Requirements

### GatewaySubnet

- **Name**: Must be exactly `GatewaySubnet`
- **Minimum size**: /27 (recommended /26 for production)
- **NSG**: Not supported (module automatically skips)
- **Purpose**: VPN Gateway or ExpressRoute Gateway
- **Address space**: Reserve from the end of VNet address space

### AzureFirewallSubnet

- **Name**: Must be exactly `AzureFirewallSubnet`
- **Minimum size**: /26 (larger for high throughput)
- **NSG**: Not supported (module automatically skips)
- **Purpose**: Azure Firewall deployment
- **Note**: Must be in the same VNet as protected resources

### AzureBastionSubnet

- **Name**: Must be exactly `AzureBastionSubnet`
- **Minimum size**: /26 or larger
- **NSG**: Optional but if used requires specific rules
- **Purpose**: Azure Bastion service for secure RDP/SSH
- **Note**: Module skips NSG creation to allow custom configuration

### AKS Subnet Considerations

```hcl
module "subnet_aks" {
  source = "./modules/subnet"
  
  name                              = "snet-aks-prod-eastus-001"
  resource_group_name               = module.resource_group.resource_group_name
  virtual_network_name              = module.virtual_network.name
  address_prefixes                  = ["10.0.8.0/22"]  # Minimum /23, recommended /22
  location                          = "eastus"
  private_endpoint_network_policies = "Enabled"
  
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.Sql",
    "Microsoft.ContainerRegistry"
  ]
  
  tags = {
    Environment = "Production"
    Workload    = "AKS"
    ManagedBy   = "Terraform"
  }  # Tags apply to the auto-created NSG only
}

# Note: Plan for at least 256 IPs (minimum) for AKS
# Formula: (max pods per node × max nodes) + control plane IPs
# Example: (30 pods × 50 nodes) + 10 = 1510 IPs → use /22 (1024 IPs)
```

## Troubleshooting

### Common Issues

**Issue**: Subnet creation fails with "address space overlaps"
- **Solution**: Ensure the address prefix doesn't overlap with existing subnets in the VNet. Use `az network vnet subnet list` to view existing allocations.

**Issue**: Service endpoint not working
- **Solution**: 
  1. Verify the PaaS service firewall allows the subnet
  2. Check NSG rules allow outbound access
  3. Ensure service endpoint is properly configured on both subnet and PaaS service

**Issue**: Cannot create resources in subnet with delegation
- **Solution**: Delegated subnets can only host the specific service they're delegated to. Create a separate subnet for other resources.

**Issue**: NSG association fails
- **Solution**: Some special subnets (GatewaySubnet, AzureFirewallSubnet) don't support NSGs. The module automatically handles this, but if manually associating, verify subnet type.

**Issue**: Private endpoint deployment fails
- **Solution**: Set `private_endpoint_network_policies = "Disabled"` for subnets hosting private endpoints.

**Issue**: Not enough IP addresses in subnet
- **Solution**: Remember Azure reserves 5 IPs per subnet. Use larger CIDR blocks if you need more addresses. Cannot resize existing subnet - must create new one.

**Issue**: GatewaySubnet not working for VPN Gateway
- **Solution**: Ensure name is exactly `GatewaySubnet` (case-sensitive) and size is at least /27.

### Validation Commands

```powershell
# List all subnets in a VNet
az network vnet subnet list --resource-group <rg-name> --vnet-name <vnet-name> --output table

# Show detailed subnet configuration
az network vnet subnet show --resource-group <rg-name> --vnet-name <vnet-name> --name <subnet-name>

# Check available IP addresses in subnet
az network vnet subnet show --resource-group <rg-name> --vnet-name <vnet-name> --name <subnet-name> --query "addressPrefix"

# List NSG rules for a subnet's NSG
az network nsg rule list --resource-group <rg-name> --nsg-name <nsg-name> --output table

# View service endpoints on subnet
az network vnet subnet show --resource-group <rg-name> --vnet-name <vnet-name> --name <subnet-name> --query "serviceEndpoints[].service"

# Check subnet delegation
az network vnet subnet show --resource-group <rg-name> --vnet-name <vnet-name> --name <subnet-name> --query "delegations"

# List resources in subnet
az network vnet subnet list-available-ips --resource-group <rg-name> --vnet-name <vnet-name> --name <subnet-name>

# Terraform validation
terraform init
terraform validate
terraform plan
```

## Cost Considerations

### Pricing Components

- **Subnets**: Free (no direct cost)
- **Network Security Groups**: Free
- **Service Endpoints**: Free
- **Private Endpoints**: 
  - ~$0.01 per hour per endpoint (~$7.30/month)
  - Inbound data processing: ~$0.01 per GB
  - Outbound data processing: Free
- **NSG Flow Logs** (if enabled separately):
  - Data ingestion and storage costs apply
  - Log Analytics ingestion charges

### Cost Optimization Tips

1. **Service Endpoints**: Use service endpoints instead of private endpoints when possible (they're free)
2. **Private Endpoints**: Consolidate multiple services behind fewer private endpoints where possible
3. **NSG Flow Logs**: Enable only for critical subnets requiring security monitoring
4. **Subnet Sizing**: Right-size subnets to avoid wasting IP address space

## Module Validation

### Pre-deployment Checklist

```powershell
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment and review
terraform plan

# Format code
terraform fmt -recursive

# Security scan (if available)
terrascan scan -d .\modules\subnet\ -i terraform
```

## Notes

- **Azure subnets do not support tags** - Tags can only be applied to the automatically created NSG
- Subnets are free; you only pay for resources deployed in them and any private endpoints
- NSG is automatically created and associated for standard subnets
- Special Azure subnets (GatewaySubnet, AzureFirewallSubnet, AzureBastionSubnet) are automatically detected and NSG creation is skipped
- Azure reserves 5 IP addresses in every subnet
- Subnet address space cannot be changed after creation
- Service endpoints route traffic over the Azure backbone network
- Private endpoints require `private_endpoint_network_policies = "Disabled"`
- Delegated subnets can only host the specific Azure service they're delegated to
- NSG rules must be added separately after subnet creation
- Maximum 3000 subnets per VNet (soft limit, can be increased)

## Module Maintenance

### Version History

- **v1.0.0** - Initial release
  - Subnet creation with configurable address prefixes
  - Automatic NSG creation and association
  - Intelligent NSG handling for special Azure subnets
  - Service endpoint support
  - Private endpoint network policies configuration
  - Subnet delegation support
  - Tagging support for NSGs (note: Azure subnets themselves don't support tags)

### Contributing

When contributing to this module:
1. Run `terraform fmt` to format code
2. Run `terraform validate` to check syntax
3. Test with both standard subnets and special Azure subnets (GatewaySubnet, etc.)
4. Verify NSG is created for standard subnets and skipped for special subnets
5. Test service endpoint configurations
6. Test subnet delegation scenarios
7. Verify private endpoint network policies behavior
8. Run security scans with Terrascan or tfsec
9. Update documentation for any new variables or outputs
10. Test in non-production environment first

## References

- [Azure Subnets Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-subnet)
- [Service Endpoints](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview)
- [Private Endpoints](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview)
- [Subnet Delegation](https://learn.microsoft.com/en-us/azure/virtual-network/subnet-delegation-overview)
- [Network Security Groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Gateway Subnet Requirements](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings#gwsub)
- [Azure Firewall Subnet Requirements](https://learn.microsoft.com/en-us/azure/firewall/firewall-faq#does-the-firewall-subnet-size-need-to-change-as-the-service-scales)
- [Azure Bastion Subnet Requirements](https://learn.microsoft.com/en-us/azure/bastion/configuration-settings#subnet)
- [AKS Network Concepts](https://learn.microsoft.com/en-us/azure/aks/concepts-network)
- [Terraform AzureRM Provider - Subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)
- [Terraform AzureRM Provider - Network Security Group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)