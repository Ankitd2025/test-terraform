# Azure Bastion Host Module

This Terraform module creates an Azure Bastion Host for secure and seamless RDP/SSH connectivity to virtual machines without exposing them to the public internet.

## Description

Azure Bastion is a fully managed PaaS service that provides secure and seamless RDP and SSH connectivity to your virtual machines directly through the Azure Portal over TLS. This module deploys Azure Bastion with configurable features including file transfer, IP-based connection, shareable links, and native client tunneling.

## Features

- ✅ Secure RDP/SSH connectivity without public IP addresses on VMs
- ✅ Connection directly through Azure Portal (HTML5-based)
- ✅ Support for both Basic and Standard SKUs
- ✅ Optional native client tunneling for SSH/RDP clients
- ✅ Optional file transfer capability (upload/download)
- ✅ Optional IP-based connectivity (connect via private IP)
- ✅ Optional shareable links for guest access
- ✅ Copy-paste functionality
- ✅ Automatic DNS name generation
- ✅ Comprehensive tagging support
- ✅ TLS 1.2 encryption for all connections

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

| Resource Type | Description | Resource Name |
|--------------|-------------|----------------|
| `azurerm_bastion_host` | The Azure Bastion Host resource | `azurerm_bastion_host` |
| `azurerm_monitor_diagnostic_setting` | Diagnostic setting (created only if `enable_diagnostic = true`) | `azurerm_monitor_diagnostic_setting` |

> **Note**: This module does **not** create the required subnet or public IP address. These must be created separately and their IDs passed to this module.
> 
> **Diagnostic Note**: The diagnostic setting is created conditionally using `count = var.enable_diagnostic ? 1 : 0`. If diagnostics are not enabled, no diagnostic setting resource is created.

## Prerequisites

Before using this module, you must have:

1. **AzureBastionSubnet**: A dedicated subnet named exactly `AzureBastionSubnet` (case-sensitive)
   - Minimum size: /26 (64 addresses)
   - Recommended size: /26 or larger
   - Must be in the same VNet as the VMs you want to access

2. **Public IP Address**: A Standard SKU public IP address
   - SKU: Standard (required)
   - Allocation: Static (required)
   - Must be in the same region as the Bastion Host

## Usage

### Basic Bastion Host (Standard SKU)

```hcl
# Create the required subnet for Bastion
module "bastion_subnet" {
  source = "./modules/subnet"
  
  name                              = "AzureBastionSubnet"
  resource_group_name               = module.resource_group.resource_group_name
  virtual_network_name              = module.virtual_network.name
  address_prefixes                  = ["10.0.253.0/27"]
  location                          = "eastus"
  private_endpoint_network_policies = "Enabled"
}

# Create public IP for Bastion
resource "azurerm_public_ip" "bastion_pip" {
  name                = "pip-bastion-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = {
    Environment = "Production"
    Service     = "Bastion"
    ManagedBy   = "Terraform"
  }
}

# Create Bastion Host
module "bastion_host" {
  source = "./modules/bastion-host"
  
  name                   = "bas-incumbentfi-prod-eastus-001"
  resource_group_name    = module.resource_group.resource_group_name
  location               = "eastus"
  subnet_id              = module.bastion_subnet.id
  public_ip_address_id   = azurerm_public_ip.bastion_pip.id
  sku                    = "Standard"
  copy_paste_enabled     = true
  file_copy_enabled      = true
  ip_connect_enabled     = true
  shareable_link_enabled = true
  tunneling_enabled      = true
  
  tags = {
    Environment = "Production"
    Service     = "Bastion"
    ManagedBy   = "Terraform"
  }
}
```

### Basic SKU Bastion Host (Cost-Optimized)

```hcl
module "bastion_host_basic" {
  source = "./modules/bastion-host"
  
  name                   = "bas-incumbentfi-dev-eastus-001"
  resource_group_name    = module.resource_group.resource_group_name
  location               = "eastus"
  subnet_id              = module.bastion_subnet.id
  public_ip_address_id   = azurerm_public_ip.bastion_pip.id
  sku                    = "Basic"
  copy_paste_enabled     = true
  file_copy_enabled      = false      # Not available in Basic SKU
  ip_connect_enabled     = false      # Not available in Basic SKU
  shareable_link_enabled = false      # Not available in Basic SKU
  tunneling_enabled      = false      # Not available in Basic SKU
  
  tags = {
    Environment = "Development"
    Service     = "Bastion"
    ManagedBy   = "Terraform"
  }
}
```

### Complete Example with Network Setup

```hcl
locals {
  common_tags = {
    Environment = "Production"
    Project     = "IncumbentFI"
    ManagedBy   = "Terraform"
  }
}

# Resource Group
module "resource_group" {
  source = "./modules/resource-group"
  
  name     = "rg-incumbentfi-prod-eastus-001"
  location = "eastus"
  tags     = local.common_tags
}

# Virtual Network
module "virtual_network" {
  source = "./modules/virtual-network"
  
  name                       = "vnet-incumbentfi-prod-eastus-001"
  address_space              = ["10.0.0.0/16"]
  location                   = "eastus"
  resource_group_name        = module.resource_group.resource_group_name
  enable_diagnostic          = true
  enable_flow_log            = false
  log_analytics_workspace_id = module.log_analytics.id
  
  tags = local.common_tags
}

# AzureBastionSubnet
module "bastion_subnet" {
  source = "./modules/subnet"
  
  name                              = "AzureBastionSubnet"
  resource_group_name               = module.resource_group.resource_group_name
  virtual_network_name              = module.virtual_network.name
  address_prefixes                  = ["10.0.253.0/26"]
  location                          = "eastus"
  private_endpoint_network_policies = "Enabled"
}

# Public IP for Bastion
resource "azurerm_public_ip" "bastion_pip" {
  name                = "pip-bastion-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = merge(local.common_tags, {
    Service = "Bastion"
  })
}

# Azure Bastion Host
module "bastion_host" {
  source = "./modules/bastion-host"
  
  name                   = "bas-incumbentfi-prod-eastus-001"
  resource_group_name    = module.resource_group.resource_group_name
  location               = "eastus"
  subnet_id              = module.bastion_subnet.id
  public_ip_address_id   = azurerm_public_ip.bastion_pip.id
  sku                    = "Standard"
  copy_paste_enabled     = true
  file_copy_enabled      = true
  ip_connect_enabled     = true
  shareable_link_enabled = false  # Disable for security
  tunneling_enabled      = true
  
  tags = merge(local.common_tags, {
    Service = "Bastion"
  })
}
```

### Multi-Region Bastion Deployment

```hcl
# East US Bastion
module "bastion_east" {
  source = "./modules/bastion-host"
  
  name                   = "bas-incumbentfi-prod-eastus-001"
  resource_group_name    = module.rg_east.resource_group_name
  location               = "eastus"
  subnet_id              = module.bastion_subnet_east.id
  public_ip_address_id   = azurerm_public_ip.bastion_pip_east.id
  sku                    = "Standard"
  copy_paste_enabled     = true
  file_copy_enabled      = true
  ip_connect_enabled     = true
  shareable_link_enabled = false
  tunneling_enabled      = true
  
  tags = local.common_tags
}

# West US Bastion
module "bastion_west" {
  source = "./modules/bastion-host"
  
  name                   = "bas-incumbentfi-prod-westus-001"
  resource_group_name    = module.rg_west.resource_group_name
  location               = "westus"
  subnet_id              = module.bastion_subnet_west.id
  public_ip_address_id   = azurerm_public_ip.bastion_pip_west.id
  sku                    = "Standard"
  copy_paste_enabled     = true
  file_copy_enabled      = true
  ip_connect_enabled     = true
  shareable_link_enabled = false
  tunneling_enabled      = true
  
  tags = local.common_tags
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | The name of the Azure Bastion Host | `string` | Yes | n/a |
| resource_group_name | The name of the resource group where the Bastion Host will be created | `string` | Yes | n/a |
| location | The Azure region where the Bastion Host will be created | `string` | Yes | n/a |
| subnet_id | The ID of the AzureBastionSubnet where the Bastion Host will be deployed | `string` | Yes | n/a |
| public_ip_address_id | The ID of the Standard SKU public IP address for the Bastion Host | `string` | Yes | n/a |
| sku | The SKU of the Bastion Host. Valid values: `Basic`, `Standard` | `string` | No | `"Standard"` |
| copy_paste_enabled | Enable or disable copy-paste functionality | `bool` | No | `true` |
| file_copy_enabled | Enable or disable file copy functionality (Standard SKU only) | `bool` | No | `true` |
| ip_connect_enabled | Enable or disable IP-based connectivity (Standard SKU only) | `bool` | No | `true` |
| shareable_link_enabled | Enable or disable shareable link functionality (Standard SKU only) | `bool` | No | `true` |
| tunneling_enabled | Enable or disable native client tunneling (Standard SKU only) | `bool` | No | `true` |
| tags | A map of tags to assign to the Bastion Host | `map(string)` | No | `{}` |
| enable_diagnostic | Whether to enable diagnostics for the Bastion Host | `bool` | Yes | n/a |
| log_analytics_workspace_id | The ID of the Log Analytics workspace to send diagnostics to | `string` | Yes (if enable_diagnostic = true) | n/a |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Bastion Host |
| name | The name of the Bastion Host |
| dns_name | The DNS name of the Bastion Host |
| location | The location of the Bastion Host |
| resource_group_name | The resource group name of the Bastion Host |

## Module Implementation Details

### IP Configuration

The Bastion Host is configured with a single IP configuration that:
- Associates the Bastion with the AzureBastionSubnet
- Assigns the public IP address (Standard SKU, Static allocation)
- Uses a standardized naming convention: `{bastion-name}-ipconfig`

```hcl
ip_configuration {
  name                 = "${var.name}-ipconfig"
  subnet_id            = var.subnet_id
  public_ip_address_id = var.public_ip_address_id
}
```

### Feature Toggle Implementation

All features are configurable through boolean variables, making it easy to enable/disable capabilities based on SKU and security requirements:

- **Basic SKU**: Only `copy_paste_enabled` is supported
- **Standard SKU**: All features can be enabled/disabled
- Features like file copy, IP connect, shareable links, and tunneling have no additional cost impact - they only affect available functionality

## Azure Naming Conventions

When naming Azure Bastion hosts, follow [Azure naming conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming):

- **Length**: 1-80 characters
- **Valid characters**: Alphanumerics, underscores, periods, and hyphens
- **Start with**: Alphanumeric
- **End with**: Alphanumeric or underscore
- **Recommended pattern**: `bas-<application>-<environment>-<region>-<instance>`

### Examples

- `bas-incumbentfi-prod-eastus-001`
- `bas-shared-prod-westus-001`
- `bas-hub-prod-centralus-001`

## SKU Comparison

### Basic SKU

**Features:**
- ✅ Connect to VMs via Azure Portal
- ✅ Copy-paste functionality
- ✅ Session recording (diagnostics)
- ❌ Native client support (az CLI, PowerShell)
- ❌ File transfer
- ❌ IP-based connection
- ❌ Shareable links
- ❌ Scale units (fixed at 2)

**Best for:** Development, test, or small production environments with basic remote access needs

### Standard SKU

**Features:**
- ✅ All Basic SKU features
- ✅ Native client support (SSH/RDP via az CLI)
- ✅ File transfer (upload/download)
- ✅ IP-based connection (connect without hostname)
- ✅ Shareable links (time-limited guest access)
- ✅ Scalable (configure scale units 2-50)
- ✅ Host scaling for performance
- ✅ Kerberos authentication support

**Best for:** Production environments requiring advanced features, native client access, or high scale

## Feature Details

### Copy-Paste Functionality

Enables clipboard access between your local machine and the target VM through the browser.

```hcl
copy_paste_enabled = true
```

**Use cases:**
- Transfer text, commands, or small data between local machine and VM
- Available in both Basic and Standard SKUs

### File Transfer (Standard SKU Only)

Enables file upload and download between your local machine and target VMs.

```hcl
file_copy_enabled = true  # Requires Standard SKU
```

**Limitations:**
- Maximum file size: 4GB
- Files transferred through secure TLS connection
- Requires Standard SKU

**Use cases:**
- Upload configuration files
- Download logs or reports
- Transfer scripts or tools

### IP-Based Connectivity (Standard SKU Only)

Connect to VMs using their private IP address instead of hostname.

```hcl
ip_connect_enabled = true  # Requires Standard SKU
```

**Use cases:**
- Connect to VMs without DNS resolution
- Useful for newly created VMs
- Connect to VMs with network configuration issues

### Shareable Links (Standard SKU Only)

Generate time-limited, secure URLs for guest access to VMs.

```hcl
shareable_link_enabled = true  # Requires Standard SKU
```

**Security considerations:**
- ⚠️ Allows external access without Azure credentials
- ⚠️ Links are time-limited but should be monitored
- ⚠️ Consider disabling in high-security environments
- ✅ Useful for contractor/vendor access
- ✅ Audit logs capture all access via shareable links

**Best practice:** Set to `false` for production environments unless specifically required.

### Native Client Tunneling (Standard SKU Only)

Connect using native SSH/RDP clients via Azure CLI tunneling.

```hcl
tunneling_enabled = true  # Requires Standard SKU
```

**Benefits:**
- Use familiar SSH/RDP clients instead of browser
- Support for SSH keys and advanced authentication
- Better performance for long sessions
- Support for port forwarding

**Usage example:**
```bash
# SSH via Bastion tunnel
az network bastion tunnel --name bas-incumbentfi-prod-eastus-001 \
  --resource-group rg-incumbentfi-prod-eastus-001 \
  --target-resource-id <vm-resource-id> \
  --resource-port 22 --port 50022

ssh user@localhost -p 50022

# RDP via Bastion tunnel
az network bastion rdp --name bas-incumbentfi-prod-eastus-001 \
  --resource-group rg-incumbentfi-prod-eastus-001 \
  --target-resource-id <vm-resource-id>
```

## Subnet Requirements

### AzureBastionSubnet Specifications

- **Name**: Must be exactly `AzureBastionSubnet` (case-sensitive)
- **Minimum size**: /26 (64 IP addresses)
- **Recommended size**: /26 or /25 for high availability
- **NSG**: Optional (but if used, must allow specific traffic)
- **Location**: Must be in the same VNet as the target VMs
- **Address planning**: Typically allocated from the end of VNet address space

### Required NSG Rules (If Using NSG)

If you attach an NSG to AzureBastionSubnet, configure these rules:

**Inbound Rules:**
```hcl
# Allow HTTPS from Internet (for client connections)
resource "azurerm_network_security_rule" "bastion_in_allow_https" {
  name                        = "AllowHttpsInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion_nsg.name
}

# Allow GatewayManager
resource "azurerm_network_security_rule" "bastion_in_allow_gm" {
  name                        = "AllowGatewayManagerInbound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "GatewayManager"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion_nsg.name
}

# Allow Azure Load Balancer
resource "azurerm_network_security_rule" "bastion_in_allow_lb" {
  name                        = "AllowAzureLoadBalancerInbound"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion_nsg.name
}

# Allow Bastion Host Communication
resource "azurerm_network_security_rule" "bastion_in_allow_bastion_host_comm" {
  name                        = "AllowBastionHostCommunication"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = ["8080", "5701"]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion_nsg.name
}
```

**Outbound Rules:**
```hcl
# Allow SSH/RDP to VMs
resource "azurerm_network_security_rule" "bastion_out_allow_ssh_rdp" {
  name                        = "AllowSshRdpOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = ["22", "3389"]
  source_address_prefix       = "*"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion_nsg.name
}

# Allow Azure Cloud
resource "azurerm_network_security_rule" "bastion_out_allow_azure_cloud" {
  name                        = "AllowAzureCloudOutbound"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureCloud"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion_nsg.name
}

# Allow Bastion Host Communication
resource "azurerm_network_security_rule" "bastion_out_allow_bastion_host_comm" {
  name                        = "AllowBastionCommunication"
  priority                    = 120
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = ["8080", "5701"]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion_nsg.name
}

# Allow GetSessionInformation
resource "azurerm_network_security_rule" "bastion_out_allow_get_session" {
  name                        = "AllowGetSessionInformation"
  priority                    = 130
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion_nsg.name
}
```

## Security Best Practices

1. **Use Standard SKU for Production**: Provides advanced security features and native client support
2. **Disable Shareable Links**: Unless specifically required, disable for enhanced security
3. **Enable Diagnostic Logging**: Monitor all Bastion access for security and compliance
4. **Use Azure RBAC**: Control who can use Bastion with Azure role-based access control
5. **Regular Updates**: Azure manages Bastion updates automatically
6. **Network Isolation**: Keep AzureBastionSubnet isolated from other workloads
7. **MFA Required**: Ensure Azure AD MFA is enforced for users accessing VMs via Bastion
8. **Session Recording**: Enable diagnostic settings to log all sessions
9. **Just-in-Time Access**: Use Azure JIT access with Bastion for additional security
10. **Monitoring**: Monitor Bastion connections via Azure Monitor and Log Analytics

## Connecting to VMs via Bastion

### Via Azure Portal

1. Navigate to your VM in Azure Portal
2. Click "Connect" → "Bastion"
3. Enter VM credentials
4. Click "Connect"

### Via Azure CLI (Standard SKU with Tunneling)

```bash
# SSH connection
az network bastion ssh --name <bastion-name> \
  --resource-group <rg-name> \
  --target-resource-id <vm-resource-id> \
  --auth-type password \
  --username <vm-username>

# RDP connection
az network bastion rdp --name <bastion-name> \
  --resource-group <rg-name> \
  --target-resource-id <vm-resource-id>

# Tunnel for native client
az network bastion tunnel --name <bastion-name> \
  --resource-group <rg-name> \
  --target-resource-id <vm-resource-id> \
  --resource-port 22 \
  --port 2222

# Then connect with native client
ssh user@localhost -p 2222
```

### Via PowerShell (Standard SKU with Tunneling)

```powershell
# Create tunnel
az network bastion tunnel --name <bastion-name> `
  --resource-group <rg-name> `
  --target-resource-id <vm-resource-id> `
  --resource-port 3389 `
  --port 3389

# Then connect with mstsc
mstsc /v:localhost:3389
```

## Monitoring and Diagnostics

### Enabling Diagnostic Settings

The module supports optional diagnostic logging to a Log Analytics workspace. To enable diagnostics, set the `enable_diagnostic` variable to `true` and provide a `log_analytics_workspace_id`.

**Basic example with diagnostics enabled:**

```hcl
module "bastion_host" {
  source = "./modules/bastion-host"
  
  name                        = "bas-incumbentfi-prod-eastus-001"
  resource_group_name         = module.resource_group.resource_group_name
  location                    = "eastus"
  subnet_id                   = module.bastion_subnet.id
  public_ip_address_id        = azurerm_public_ip.bastion_pip.id
  sku                         = "Standard"
  enable_diagnostic           = true
  log_analytics_workspace_id  = module.log_analytics.id
  
  tags = {
    Environment = "Production"
    Service     = "Bastion"
    ManagedBy   = "Terraform"
  }
}
```

**Example with diagnostics disabled:**

```hcl
module "bastion_host" {
  source = "./modules/bastion-host"
  
  name                        = "bas-incumbentfi-dev-eastus-001"
  resource_group_name         = module.resource_group.resource_group_name
  location                    = "eastus"
  subnet_id                   = module.bastion_subnet.id
  public_ip_address_id        = azurerm_public_ip.bastion_pip.id
  sku                         = "Standard"
  enable_diagnostic           = false
  log_analytics_workspace_id  = ""
  
  tags = {
    Environment = "Development"
    Service     = "Bastion"
    ManagedBy   = "Terraform"
  }
}
```

### Diagnostic Setting Details

When diagnostics are enabled, the module creates an `azurerm_monitor_diagnostic_setting` resource that:

- **Name**: Automatically generated as `diag-{bastion-host-name}`
- **Target Resource**: The Bastion Host resource
- **Logs**: All log categories are enabled (`allLogs`)
- **Metrics**: All metrics are captured (`AllMetrics`)
- **Destination**: Sends data to the specified Log Analytics workspace

### Diagnostic Setting Configuration

```hcl
resource "azurerm_monitor_diagnostic_setting" "azurerm_monitor_diagnostic_setting" {
  count                      = var.enable_diagnostic ? 1 : 0
  name                       = "diag-${azurerm_bastion_host.azurerm_bastion_host.name}"
  target_resource_id         = azurerm_bastion_host.azurerm_bastion_host.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
```

### Log Analytics Workspace Example

```hcl
module "log_analytics" {
  source = "./modules/log-analytics-workspaces"
  
  name                = "law-incumbentfi-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Key Metrics to Monitor

- **Session Count**: Number of active Bastion sessions
- **Total Connections**: Total connection attempts
- **Used Capacity**: Percentage of Bastion capacity in use
- **Failed Connections**: Number of failed connection attempts

### Audit Logs

Bastion audit logs capture:
- User principal name (who connected)
- Target VM resource ID
- Connection start/end time
- Session duration
- Protocol used (SSH/RDP)
- Source IP address

### Querying Diagnostic Data in Log Analytics

**Find all connection attempts:**

```kusto
AzureDiagnostics
| where ResourceType == "BASTIONHOSTS"
| where OperationName contains "Connect"
| project TimeGenerated, UserPrincipalName, OperationName, ResultDescription
```

**Analyze failed connections:**

```kusto
AzureDiagnostics
| where ResourceType == "BASTIONHOSTS"
| where ResultType == "Failed"
| summarize FailureCount = count() by UserPrincipalName, ResultDescription
```

**Monitor session duration:**

```kusto
AzureDiagnostics
| where ResourceType == "BASTIONHOSTS"
| where OperationName == "SessionCreated" or OperationName == "SessionEnded"
| project TimeGenerated, UserPrincipalName, SessionId = DurationMs
```

## Troubleshooting

### Common Issues

**Issue**: Cannot connect to VM via Bastion
- **Solution**: 
  1. Verify VM is running
  2. Ensure VM is in the same VNet or peered VNet
  3. Check VM's NSG allows RDP (3389) or SSH (22) from AzureBastionSubnet
  4. Verify you have "Virtual Machine User Login" or "Virtual Machine Administrator Login" role

**Issue**: Bastion deployment fails
- **Solution**: 
  1. Ensure subnet is named exactly `AzureBastionSubnet`
  2. Verify subnet is at least /26
  3. Ensure public IP is Standard SKU with Static allocation
  4. Check that public IP and Bastion are in the same region

**Issue**: File copy not working
- **Solution**: 
  1. Verify Standard SKU is being used (file copy requires Standard)
  2. Check file size is under 4GB
  3. Ensure `file_copy_enabled = true`
  4. Verify browser supports file transfer features

**Issue**: Native client tunneling not working
- **Solution**: 
  1. Ensure Standard SKU is deployed
  2. Verify `tunneling_enabled = true`
  3. Update Azure CLI to latest version: `az upgrade`
  4. Check firewall allows outbound 443 to Azure

**Issue**: Shareable links not working
- **Solution**: 
  1. Ensure Standard SKU with `shareable_link_enabled = true`
  2. Verify link hasn't expired
  3. Check that user has network connectivity to Azure
  4. Ensure link permissions are correctly configured

### Validation Commands

```powershell
# Check Bastion status
az network bastion show --name <bastion-name> --resource-group <rg-name>

# List all Bastion hosts in subscription
az network bastion list --output table

# Test connectivity to VM via Bastion (Standard SKU)
az network bastion ssh --name <bastion-name> \
  --resource-group <rg-name> \
  --target-resource-id <vm-id> \
  --auth-type password \
  --username <user>

# View Bastion shareable links (if enabled)
az network bastion shareable-link list --name <bastion-name> \
  --resource-group <rg-name>

# Check public IP configuration
az network public-ip show --name <pip-name> --resource-group <rg-name>

# Verify subnet configuration
az network vnet subnet show --resource-group <rg-name> \
  --vnet-name <vnet-name> \
  --name AzureBastionSubnet

# Terraform validation
terraform init
terraform validate
terraform plan
```

## Module Validation

### Pre-deployment Checklist

```powershell
# Verify subnet exists and is correctly named
az network vnet subnet show --resource-group <rg-name> \
  --vnet-name <vnet-name> \
  --name AzureBastionSubnet

# Verify public IP is correct SKU and allocation
az network public-ip show --name <pip-name> \
  --resource-group <rg-name> \
  --query "{SKU:sku.name, Allocation:publicIpAllocationMethod}"

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment
terraform plan

# Format code
terraform fmt -recursive

# Check for security issues
terrascan scan -d .\modules\bastion-host\ -i terraform
```

## Notes

- Azure Bastion is a fully managed PaaS service - no maintenance required
- Bastion automatically scales to handle increased connection load (Standard SKU)
- All connections are TLS encrypted
- Bastion eliminates the need for public IPs on VMs
- Works with both Windows (RDP) and Linux (SSH) VMs
- Supports Azure AD authentication when using native client tunneling
- Session recordings are available via diagnostic logs
- Maximum file size for transfer: 4GB (Standard SKU)
- Bastion can be used with VMs in peered VNets
- No agent or client software required (browser-based)
- Requires Standard SKU public IP with static allocation
- AzureBastionSubnet must be at least /26

## Module Maintenance

### Version History

- **v1.0.0** - Initial release
  - Azure Bastion Host deployment
  - Support for Basic and Standard SKUs
  - All Standard SKU features: file copy, IP connect, shareable links, tunneling
  - Copy-paste functionality
  - Automatic DNS name generation
  - Comprehensive tagging support
  - Configurable feature toggles

### Contributing

When contributing to this module:
1. Run `terraform fmt` to format code
2. Run `terraform validate` to check syntax
3. Test with both Basic and Standard SKUs
4. Verify all feature toggles work correctly
5. Test connections to both Windows and Linux VMs
6. Verify DNS name generation
7. Test native client tunneling (Standard SKU)
8. Run security scans with Terrascan or tfsec
9. Update documentation for any new variables or outputs
10. Test in non-production environment first

## References

- [Azure Bastion Documentation](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview)
- [Azure Bastion FAQ](https://learn.microsoft.com/en-us/azure/bastion/bastion-faq)
- [Connect to VM using Azure Bastion](https://learn.microsoft.com/en-us/azure/bastion/bastion-connect-vm-ssh)
- [Azure Bastion Native Client Support](https://learn.microsoft.com/en-us/azure/bastion/native-client)
- [Azure Bastion Configuration Settings](https://learn.microsoft.com/en-us/azure/bastion/configuration-settings)
- [Azure Bastion Monitoring](https://learn.microsoft.com/en-us/azure/bastion/howto-metrics-monitor-alert)
- [Azure Bastion NSG Requirements](https://learn.microsoft.com/en-us/azure/bastion/bastion-nsg)
- [Azure Bastion SKU](https://learn.microsoft.com/en-us/azure/bastion/configuration-settings#skus)
- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Terraform AzureRM Provider - Bastion Host](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host)
- [Azure Bastion Video Tutorials](https://learn.microsoft.com/en-us/shows/azure-videos/azure-bastion)