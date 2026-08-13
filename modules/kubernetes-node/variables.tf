# Variables for the Azure Kubernetes Service user node pool module
variable "name" {
	description = "The name of the AKS user node pool."
	type        = string
}

variable "kubernetes_cluster_id" {
	description = "The ID of the AKS cluster where this user node pool will be created."
	type        = string
}

variable "vm_size" {
	description = "The VM size for the AKS user node pool."
	type        = string
}

variable "vnet_subnet_id" {
	description = "The subnet ID where the AKS user node pool will be deployed."
	type        = string
}

variable "orchestrator_version" {
	description = "The Kubernetes version for the user node pool. Leave null to inherit the cluster-compatible default."
	type        = string
	default     = null
}

variable "auto_scaling_enabled" {
	description = "Whether cluster autoscaler is enabled for this user node pool."
	type        = bool
	default     = true
}

variable "node_count" {
	description = "The fixed node count when autoscaling is disabled."
	type        = number
	default     = 2
}

variable "min_count" {
	description = "The minimum node count when autoscaling is enabled."
	type        = number
	default     = 2
}

variable "max_count" {
	description = "The maximum node count when autoscaling is enabled."
	type        = number
	default     = 6
}

variable "zones" {
	description = "The availability zones for the user node pool."
	type        = list(string)
	default     = ["1", "2", "3"]
}

variable "os_type" {
	description = "The operating system type for the user node pool."
	type        = string
	default     = "Linux"

	validation {
		condition     = contains(["Linux", "Windows"], var.os_type)
		error_message = "The os_type value must be Linux or Windows."
	}
}

variable "os_sku" {
	description = "The OS SKU for user node pool nodes."
	type        = string
	default     = "AzureLinux"

	validation {
		condition     = contains(["AzureLinux", "AzureLinux3", "Ubuntu", "Ubuntu2204", "Ubuntu2404", "Windows2019", "Windows2022"], var.os_sku)
		error_message = "The os_sku value must be AzureLinux, AzureLinux3, Ubuntu, Ubuntu2204, Ubuntu2404, Windows2019, or Windows2022."
	}
}

variable "os_disk_size_gb" {
	description = "The OS disk size in GB for user node pool nodes."
	type        = number
	default     = 128
}

variable "os_disk_type" {
	description = "The OS disk type for user node pool nodes."
	type        = string
	default     = "Managed"

	validation {
		condition     = contains(["Ephemeral", "Managed"], var.os_disk_type)
		error_message = "The os_disk_type value must be Ephemeral or Managed."
	}
}

variable "host_encryption_enabled" {
	description = "Whether host encryption is enabled on the user node pool. Requires Azure feature registration."
	type        = bool
	default     = false
}

variable "fips_enabled" {
	description = "Whether FIPS mode is enabled on the user node pool. Requires supported VM sizes and OS images."
	type        = bool
	default     = false
}

variable "max_pods" {
	description = "The maximum number of pods that can run on each user node."
	type        = number
	default     = 30
}

variable "node_labels" {
	description = "A map of Kubernetes labels to apply to user node pool nodes."
	type        = map(string)
	default     = {}
}

variable "node_taints" {
	description = "A list of Kubernetes taints to apply to user node pool nodes."
	type        = list(string)
	default     = []
}

variable "temporary_name_for_rotation" {
	description = "The temporary node pool name used when Terraform must rotate the node pool for immutable property changes."
	type        = string
	default     = "tmpuser"
}

variable "scale_down_mode" {
	description = "The scale-down behavior for the user node pool."
	type        = string
	default     = "Delete"

	validation {
		condition     = contains(["Delete", "Deallocate"], var.scale_down_mode)
		error_message = "The scale_down_mode value must be Delete or Deallocate."
	}
}

variable "max_surge" {
	description = "The maximum surge value for user node pool upgrades."
	type        = string
	default     = "10%"
}

variable "tags" {
	description = "A map of tags to assign to the AKS user node pool."
	type        = map(string)
	default     = {}
}
