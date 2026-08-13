# Azure Linux Virtual Machine Module

This Terraform module creates an Azure Linux Virtual Machine with configurable networking, storage, authentication, and security options.

## Description

This module simplifies the deployment of Linux virtual machines on Azure with SSH key-based authentication, optional disk encryption, managed identity, and network security configuration. It provides a flexible foundation for deploying secure Linux VMs with support for various Ubuntu distributions and custom networking configurations.

## Features

- ✅ SSH key-based authentication (no passwords)
- ✅ Configurable VM size and region
- ✅ Optional disk encryption with customer-managed keys
- ✅ System-assigned managed identity
- ✅ Optional public IP address attachment
- ✅ Static or dynamic IP allocation
- ✅ Network Security Group with customizable rules
- ✅ Support for multiple Ubuntu distributions
- ✅ Configurable OS and data disk storage
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
| `azurerm_linux_virtual_machine` | The Linux virtual machine |
| `azurerm_network_interface` | Primary network interface for the VM |
| `azurerm_network_security_group` | Network security group for network access control |

## Usage

### Basic Linux VM with SSH Authentication

```hcl
module "linux_vm" {
  source = "./modules/linux-virtual-machine"
  
  name                = "vm-app-prod-eastus-001"
  resource_group_name = module.resource_group.resource_group_name
  location            = "eastus"
  size                = "Standard_B2s"
  admin_username      = "azureuser"
  admin_ssh_public_key = file("~/.ssh/id_rsa.pub")
  
  subnet_id                       = module.subnet.id
  private_ip_allocation_method    = "Dynamic"
  allow_public_access             = false
  
  os_disk_caching              = "ReadWrite"
  os_disk_storage_account_type = "Premium_LRS"
  os_disk_size_gb              = 30
  
  enable_disk_encryption = false
  
  source_image_publisher = "Canonical"
  source_image_offer     = "0001-com-ubuntu-server-jammy"
  source_image_sku       = "22_04-lts-gen2"
  source_image_version   = "latest"
  
  enable_monitoring_extension    = false
  enable_guest_configuration     = false
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Linux VM with Static IP and Public Access

```hcl
module "linux_vm_public" {
  source = "./modules/linux-virtual-machine"
  
  name                = "vm-web-prod-eastus-001"
  resource_group_name = module.resource_group.resource_group_name
  location            = "eastus"
  size                = "Standard_D2s_v3"
  admin_username      = "azureuser"
  admin_ssh_public_key = file("~/.ssh/id_rsa.pub")
  
  subnet_id                       = module.subnet.id
  private_ip_allocation_method    = "Static"
  private_ip_address              = "10.0.1.20"
  allow_public_access             = true
  public_ip_address_id            = azurerm_public_ip.vm_pip.id
  
  os_disk_caching              = "ReadWrite"
  os_disk_storage_account_type = "Premium_LRS"
  os_disk_size_gb              = 50
  
  enable_disk_encryption = false
  
  source_image_publisher = "Canonical"
  source_image_offer     = "0001-com-ubuntu-server-jammy"
  source_image_sku       = "22_04-lts-gen2"
  source_image_version   = "latest"
  
  tags = {
    Environment = "Production"
    Service     = "WebServer"
  }
}

# Associated public IP
resource "azurerm_public_ip" "vm_pip" {
  name                = "pip-vm-web-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}
```

### Linux VM with Disk Encryption (PCI Compliance)

```hcl
module "linux_vm_encrypted" {
  source = "./modules/linux-virtual-machine"
  
  name                = "vm-db-prod-eastus-001"
  resource_group_name = module.resource_group.resource_group_name
  location            = "eastus"
  size                = "Standard_D4s_v3"
  admin_username      = "azureuser"
  admin_ssh_public_key = file("~/.ssh/id_rsa.pub")
  
  subnet_id                       = module.subnet.id
  private_ip_allocation_method    = "Static"
  private_ip_address              = "10.0.1.30"
  allow_public_access             = false
  
  os_disk_caching              = "ReadWrite"
  os_disk_storage_account_type = "Premium_LRS"
  os_disk_size_gb              = 100
  
  # Enable disk encryption with customer-managed key
  enable_disk_encryption = true
  disk_encryption_set_id = module.disk_encryption_set.disk_encryption_set_id
  
  source_image_publisher = "Canonical"
  source_image_offer     = "0001-com-ubuntu-server-jammy"
  source_image_sku       = "22_04-lts-gen2"
  source_image_version   = "latest"
  
  tags = {
    Environment = "Production"
    Compliance  = "PCI-DSS"
    Service     = "Database"
  }
}
```

### Complete Enterprise Deployment

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
  
  name     = "rg-prod-eastus-001"
  location = "eastus"
  tags     = local.common_tags
}

# Virtual Network and Subnet
module "vnet" {
  source = "./modules/virtual-network"
  
  name                = "vnet-prod-eastus-001"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  tags                = local.common_tags
}

module "subnet" {
  source = "./modules/subnet"
  
  name                = "subnet-apps-prod"
  resource_group_name = module.resource_group.resource_group_name
  vnet_name           = module.vnet.name
  address_prefixes    = ["10.0.1.0/24"]
}

# Public IP for VM
resource "azurerm_public_ip" "vm_pip" {
  name                = "pip-vm-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = local.common_tags
}

# Disk Encryption Set (for PCI compliance)
module "disk_encryption_set" {
  source = "./modules/disk-encryption-set"
  
  name                = "des-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  key_vault_key_id    = azurerm_key_vault_key.vm_encryption_key.id
  
  tags = local.common_tags
}

# Linux VM
module "linux_vm" {
  source = "./modules/linux-virtual-machine"
  
  name                = "vm-app-prod-eastus-001"
  resource_group_name = module.resource_group.resource_group_name
  location            = "eastus"
  size                = "Standard_D2s_v3"
  
  admin_username       = "azureuser"
  admin_ssh_public_key = file("~/.ssh/id_rsa.pub")
  
  subnet_id                       = module.subnet.id
  private_ip_allocation_method    = "Static"
  private_ip_address              = "10.0.1.10"
  allow_public_access             = true
  public_ip_address_id            = azurerm_public_ip.vm_pip.id
  
  os_disk_caching              = "ReadWrite"
  os_disk_storage_account_type = "Premium_LRS"
  os_disk_size_gb              = 50
  
  enable_disk_encryption = true
  disk_encryption_set_id = module.disk_encryption_set.disk_encryption_set_id
  
  source_image_publisher = "Canonical"
  source_image_offer     = "0001-com-ubuntu-server-jammy"
  source_image_sku       = "22_04-lts-gen2"
  source_image_version   = "latest"
  
  tags = merge(local.common_tags, {
    Service = "Application"
  })
  
  depends_on = [
    module.subnet,
    azurerm_public_ip.vm_pip
  ]
}

# Output the VM details
output "vm_id" {
  value = module.linux_vm.linux_virtual_machine_id
}

output "vm_private_ip" {
  value = module.linux_vm.linux_virtual_machine_private_ip
}

output "vm_public_ip" {
  value = azurerm_public_ip.vm_pip.ip_address
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | The name of the Linux virtual machine | `string` | Yes | n/a |
| resource_group_name | The name of the resource group | `string` | Yes | n/a |
| location | The Azure region for the VM | `string` | Yes | n/a |
| size | The VM size (e.g., Standard_B2s, Standard_D2s_v3) | `string` | Yes | n/a |
| admin_username | The admin username for SSH access | `string` | Yes | n/a |
| admin_ssh_public_key | The SSH public key for authentication | `string` | Yes | n/a |
| subnet_id | The ID of the subnet where VM will be connected | `string` | Yes | n/a |
| private_ip_allocation_method | IP allocation method: Dynamic or Static | `string` | Yes | n/a |
| private_ip_address | Static private IP (required if allocation is Static) | `string` | No | `null` |
| allow_public_access | Whether to attach a public IP | `bool` | Yes | n/a |
| public_ip_address_id | The ID of the public IP (required if allow_public_access is true) | `string` | No | `null` |
| os_disk_caching | OS disk caching: None, ReadOnly, ReadWrite | `string` | Yes | n/a |
| os_disk_storage_account_type | OS disk storage type: Standard_LRS, Premium_LRS, StandardSSD_LRS | `string` | Yes | n/a |
| os_disk_size_gb | OS disk size in GB | `number` | Yes | n/a |
| enable_disk_encryption | Enable disk encryption with customer-managed key | `bool` | Yes | n/a |
| disk_encryption_set_id | ID of disk encryption set (required if encryption enabled) | `string` | No | `null` |
| source_image_publisher | Image publisher (e.g., Canonical) | `string` | Yes | n/a |
| source_image_offer | Image offer (e.g., 0001-com-ubuntu-server-jammy) | `string` | Yes | n/a |
| source_image_sku | Image SKU (e.g., 22_04-lts-gen2) | `string` | Yes | n/a |
| source_image_version | Image version (e.g., latest) | `string` | Yes | n/a |
| enable_monitoring_extension | Enable monitoring/logging extensions | `bool` | Yes | n/a |
| enable_guest_configuration | Enable guest configuration compliance checking | `bool` | Yes | n/a |
| tags | Tags to assign to resources | `map(string)` | No | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| linux_virtual_machine_id | The ID of the Linux virtual machine |
| linux_virtual_machine_name | The name of the Linux virtual machine |
| linux_virtual_machine_resource_group_name | The resource group name of the VM |
| linux_virtual_machine_location | The location of the Linux virtual machine |
| linux_virtual_machine_os_disk_id | The ID of the OS disk |
| linux_virtual_machine_private_ip | The private IP address of the VM |
| linux_virtual_machine_principal_id | The principal ID of the system-assigned managed identity |
| network_interface_id | The ID of the primary network interface |
| nsg_id | The ID of the network security group |

## Supported Linux Distributions

### Ubuntu Server 22.04 LTS (Gen2) - Recommended

```hcl
source_image_publisher = "Canonical"
source_image_offer     = "0001-com-ubuntu-server-jammy"
source_image_sku       = "22_04-lts-gen2"
source_image_version   = "latest"
```

### Ubuntu Server 20.04 LTS (Gen2)

```hcl
source_image_publisher = "Canonical"
source_image_offer     = "0001-com-ubuntu-server-focal"
source_image_sku       = "20_04-lts-gen2"
source_image_version   = "latest"
```

### Ubuntu Server 18.04 LTS

```hcl
source_image_publisher = "Canonical"
source_image_offer     = "UbuntuServer"
source_image_sku       = "18_04-lts-gen2"
source_image_version   = "latest"
```

## VM Size Selection

### Development/Test Sizes

- `Standard_B1s` - 1 vCPU, 1 GB RAM (lowest cost)
- `Standard_B2s` - 2 vCPU, 4 GB RAM (light workloads)
- `Standard_B2ms` - 2 vCPU, 8 GB RAM (burstable)

### General Purpose

- `Standard_D2s_v3` - 2 vCPU, 8 GB RAM
- `Standard_D4s_v3` - 4 vCPU, 16 GB RAM
- `Standard_D8s_v3` - 8 vCPU, 32 GB RAM

### Compute Optimized

- `Standard_F2s_v2` - 2 vCPU, 4 GB RAM
- `Standard_F4s_v2` - 4 vCPU, 8 GB RAM

### Memory Optimized

- `Standard_E2s_v3` - 2 vCPU, 16 GB RAM
- `Standard_E4s_v3` - 4 vCPU, 32 GB RAM

## Storage Configuration

### OS Disk Caching

- **None** - No caching (safest for data integrity)
- **ReadOnly** - Cache reads only
- **ReadWrite** - Cache reads and writes (default, best performance)

### Storage Account Types

- **Standard_LRS** - Standard SSD, locally redundant (cost-effective)
- **StandardSSD_LRS** - Standard SSD with better performance
- **Premium_LRS** - Premium SSD (recommended for production)
- **UltraSSD_LRS** - Ultra SSD (highest performance)

## SSH Key Authentication

### Generate SSH Key Pair (if not exists)

```bash
# Generate new SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Get the public key for use in Terraform
cat ~/.ssh/id_rsa.pub
```

### Using SSH Key in Terraform

```hcl
module "linux_vm" {
  # ... other configuration ...
  
  admin_ssh_public_key = file("~/.ssh/id_rsa.pub")
}
```

### Connect to VM via SSH

```bash
# Connect using SSH key
ssh -i ~/.ssh/id_rsa azureuser@<public_ip_or_dns>

# Alternative: using the private IP (if on same network)
ssh -i ~/.ssh/id_rsa azureuser@<private_ip>
```

## Network Configuration

### Dynamic IP Allocation

```hcl
module "linux_vm" {
  private_ip_allocation_method = "Dynamic"
  private_ip_address           = null
  allow_public_access          = false
}
```

### Static IP Allocation

```hcl
module "linux_vm" {
  private_ip_allocation_method = "Static"
  private_ip_address           = "10.0.1.20"
  allow_public_access          = false
}
```

### With Public IP

```hcl
resource "azurerm_public_ip" "vm_pip" {
  name                = "pip-vm-prod-eastus-001"
  location            = "eastus"
  resource_group_name = module.resource_group.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

module "linux_vm" {
  allow_public_access  = true
  public_ip_address_id = azurerm_public_ip.vm_pip.id
}
```

## Disk Encryption

### Without Encryption

```hcl
enable_disk_encryption = false
disk_encryption_set_id = null
```

### With Customer-Managed Key Encryption

```hcl
enable_disk_encryption = true
disk_encryption_set_id = module.disk_encryption_set.disk_encryption_set_id
```

**Note:** Disk encryption requires:
1. Disk Encryption Set to be created first
2. Encryption set's managed identity to have Key Vault permissions
3. Key Vault key to be properly configured

## Managed Identity

The module automatically creates a system-assigned managed identity for the VM, which:

- Enables secure authentication to Azure services
- Eliminates need for storing credentials in code
- Provides audit trail for service access
- Can be used with Azure Key Vault, Storage, etc.

```hcl
# Access the principal ID for RBAC assignments
output "vm_principal_id" {
  value = module.linux_vm.linux_virtual_machine_principal_id
}

# Use in RBAC role assignment
resource "azurerm_role_assignment" "vm_key_vault_access" {
  scope              = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id       = module.linux_vm.linux_virtual_machine_principal_id
}
```

## Troubleshooting

### Common Issues

**Issue**: SSH connection denied after VM creation
- **Solution**:
  1. Verify SSH public key was correctly provided
  2. Check public IP is assigned if public access enabled
  3. Verify NSG allows SSH (port 22) from your IP
  4. Ensure VM is fully provisioned (wait 2-3 minutes)

**Issue**: VM creation fails with encryption error
- **Solution**:
  1. Verify `disk_encryption_set_id` is provided if `enable_disk_encryption = true`
  2. Ensure encryption set exists and is valid
  3. Check managed identity has Key Vault permissions

**Issue**: Static IP assignment fails
- **Solution**:
  1. Ensure `private_ip_allocation_method = "Static"`
  2. Verify IP is within subnet range (e.g., 10.0.1.0/24)
  3. Ensure IP is not already in use

**Issue**: Public IP not accessible
- **Solution**:
  1. Verify `allow_public_access = true`
  2. Ensure `public_ip_address_id` is provided
  3. Check NSG allows inbound traffic
  4. Verify public IP allocation is Static

### Validation Commands

```bash
# List VM details
az vm show --name vm-app-prod-eastus-001 \
  --resource-group rg-prod-001 --output table

# Check VM status
az vm get-instance-view --name vm-app-prod-eastus-001 \
  --resource-group rg-prod-001 \
  --query instanceView.statuses

# Get VM IP addresses
az vm show --name vm-app-prod-eastus-001 \
  --resource-group rg-prod-001 \
  --show-details --output table

# Start/Stop VM
az vm start --name vm-app-prod-eastus-001 --resource-group rg-prod-001
az vm stop --name vm-app-prod-eastus-001 --resource-group rg-prod-001

# Test SSH connectivity
ssh -vvv -i ~/.ssh/id_rsa azureuser@<public_ip>

# Terraform validation
terraform validate
terraform plan
```

## Module Validation

### Pre-deployment Checklist

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment to see what will be created
terraform plan -out=tfplan

# Format code
terraform fmt -recursive

# Security scan
terrascan scan -d ./modules/linux-virtual-machine -i terraform

# Check for errors
terraform validate
```

## Notes

- **SSH Keys Only**: Passwords are completely disabled; SSH keys are mandatory
- **Managed Disks**: Only managed disks are supported
- **Regional**: VM must be created in the same region as its virtual network
- **Network Interface**: One primary network interface is created automatically
- **NSG**: Basic NSG is created; add rules as needed for your workload
- **Tagging**: Tags are applied to VM, NIC, and NSG for consistency
- **Cost**: Costs depend on VM size, storage type, and region
- **Availability**: Consider using Availability Sets/Zones for high availability
- **Extensions**: Monitoring and guest configuration are optional
- **Image Updates**: Use `latest` version to get security patches automatically

## Module Maintenance

### Version History

- **v1.0.0** - Initial release
  - Linux VM creation with SSH authentication
  - Configurable networking and storage
  - Optional disk encryption support
  - System-assigned managed identity
  - Network security group

### Contributing

When contributing to this module:
1. Run `terraform fmt` to format code
2. Run `terraform validate` to check syntax
3. Test with different VM sizes
4. Test with and without public IP
5. Verify disk encryption configuration
6. Test static and dynamic IP allocation
7. Run security scans with Terrascan or tfsec
8. Update documentation for any new variables or outputs

## References

- [Azure Linux Virtual Machines Documentation](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/)
- [Terraform AzureRM Provider - Linux VM](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine)
- [SSH Key-Based Authentication](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys)
- [Azure VM Sizes](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes)
- [Managed Identities for Azure Resources](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)
- [Network Security Groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- [Azure Disk Encryption](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/disk-encryption-overview)
- [Ubuntu on Azure](https://learn.microsoft.com/en-us/azure/virtual-machines/workloads/ubuntu/about)
