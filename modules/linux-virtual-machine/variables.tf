# Variables for Azure Linux Virtual Machine module
variable "name" {
  description = "The name of the Linux virtual machine."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Linux virtual machine."
  type        = string
}

variable "location" {
  description = "The location/region where the Linux virtual machine will be created."
  type        = string
}

variable "size" {
  description = "The size of the Linux virtual machine (e.g., 'Standard_DS1_v2')."
  type        = string
}

variable "admin_username" {
  description = "The administrator username for the Linux virtual machine."
  type        = string
}

variable "admin_ssh_public_key" {
  description = "The SSH public key for the administrator account on the Linux virtual machine."
  type        = string
}

variable "os_disk_caching" {
  description = "The caching type for the OS disk. Valid values are 'None', 'ReadOnly', and 'ReadWrite'."
  type        = string
}

variable "os_disk_storage_account_type" {
  description = "The storage account type for the OS disk. Valid values are 'Standard_LRS', 'Premium_LRS', and 'StandardSSD_LRS'."
  type        = string
}

variable "os_disk_size_gb" {
  description = "The size of the OS disk in GB."
  type        = number
}

variable "source_image_publisher" {
  description = "The publisher of the source image to use for the Linux virtual machine."
  type        = string
}

variable "source_image_offer" {
  description = "The offer of the source image to use for the Linux virtual machine."
  type        = string
}

variable "source_image_sku" {
  description = "The SKU of the source image to use for the Linux virtual machine."
  type        = string
}

variable "source_image_version" {
  description = "The version of the source image to use for the Linux virtual machine. Use 'latest' to always use the latest version."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to which the Linux virtual machine will be connected."
  type        = string
}

variable "private_ip_allocation_method" {
  description = "The method to use for allocating the private IP address. Valid values are 'Dynamic' and 'Static'."
  type        = string
}

variable "private_ip_address" {
  description = "The private IP address to assign to the Linux virtual machine. Required if 'private_ip_allocation_method' is set to 'Static'."
  type        = string
  default     = null
}

variable "allow_public_access" {
  description = "Whether to allow public access to the Linux virtual machine. If true, a public IP address will be associated with the network interface."
  type        = bool
}

variable "public_ip_address_id" {
  description = "The ID of the public IP address to associate with the Linux virtual machine. Required if 'allow_public_access' is true."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the Linux virtual machine."
  type        = map(string)
  default     = {}
}

