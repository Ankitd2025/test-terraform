variable "name" {
  description = "The name of the Windows virtual machine."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Windows virtual machine."
  type        = string
}

variable "location" {
  description = "The Azure region where the Windows virtual machine will be created."
  type        = string
}

variable "size" {
  description = "The size of the Windows virtual machine."
  type        = string
}

variable "admin_username" {
  description = "The administrator username for the Windows virtual machine."
  type        = string
}

variable "admin_password" {
  description = "The administrator password for the Windows virtual machine."
  type        = string
  sensitive   = true
}

variable "subnet_id" {
  description = "The subnet ID for the Windows virtual machine network interface."
  type        = string
}

variable "private_ip_allocation_method" {
  description = "The private IP allocation method. Valid values are Dynamic and Static."
  type        = string
  default     = "Dynamic"
}

variable "private_ip_address" {
  description = "The static private IP address for the VM NIC. Required when private_ip_allocation_method is Static."
  type        = string
  default     = null
}

variable "allow_public_access" {
  description = "Whether to attach a public IP address to the VM NIC."
  type        = bool
  default     = false
}

variable "public_ip_address_id" {
  description = "The public IP address ID to attach when allow_public_access is true."
  type        = string
  default     = null
}

variable "allowed_inbound_rules" {
  description = "Optional inbound allow rules. Leave empty for private, deny-by-default inbound access from the VNet."
  type = map(object({
    priority                = number
    protocol                = string
    destination_port_ranges = list(string)
    source_address_prefixes = list(string)
  }))
  default = {}
}

variable "os_disk_caching" {
  description = "The caching type for the OS disk."
  type        = string
  default     = "ReadWrite"
}

variable "os_disk_storage_account_type" {
  description = "The storage account type for the OS disk."
  type        = string
  default     = "Premium_LRS"
}

variable "os_disk_size_gb" {
  description = "The OS disk size in GB."
  type        = number
  default     = 128
}

variable "enable_disk_encryption" {
  description = "Whether to use a disk encryption set for the OS disk."
  type        = bool
  default     = true
}

variable "disk_encryption_set_id" {
  description = "The disk encryption set ID for OS disk CMK encryption."
  type        = string
  default     = null
}

variable "source_image_publisher" {
  description = "The publisher of the source image."
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "source_image_offer" {
  description = "The offer of the source image."
  type        = string
  default     = "WindowsServer"
}

variable "source_image_sku" {
  description = "The SKU of the source image."
  type        = string
  default     = "2022-datacenter-azure-edition"
}

variable "source_image_version" {
  description = "The version of the source image."
  type        = string
  default     = "latest"
}

variable "encryption_at_host_enabled" {
  description = "Whether encryption at host is enabled."
  type        = bool
  default     = true
}

variable "secure_boot_enabled" {
  description = "Whether secure boot is enabled."
  type        = bool
  default     = true
}

variable "vtpm_enabled" {
  description = "Whether vTPM is enabled."
  type        = bool
  default     = true
}

variable "patch_mode" {
  description = "The Windows VM patch mode."
  type        = string
  default     = "AutomaticByPlatform"
}

variable "enable_monitoring_extension" {
  description = "Whether to install Azure Monitor Agent."
  type        = bool
  default     = true
}

variable "enable_guest_configuration" {
  description = "Whether to install the Guest Configuration extension for compliance policy checks."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the Windows virtual machine resources."
  type        = map(string)
  default     = {}
}
