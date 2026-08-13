# Azure Kubernetes Service Module

This module deploys a PCI-aligned Azure Kubernetes Service cluster with private API access, Microsoft Entra RBAC, Azure Policy, managed identity, workload identity, optional CMK disk encryption, Key Vault Secrets Provider, Log Analytics integration, Microsoft Defender, and diagnostic settings.

## Example

```hcl
module "azurerm_kubernetes_cluster" {
	source                     = "../../modules/kubernetes"
	name                       = lower("aks-${local.resources_name_suffix}")
	resource_group_name        = module.azurerm_resource_group.resource_group_name
	location                   = local.region
	dns_prefix                 = lower("aks-${local.resources_name_suffix}")
	tenant_id                  = data.azurerm_client_config.azurerm_client_config.tenant_id
	admin_group_object_ids     = var.aks_admin_group_object_ids
	vnet_subnet_id             = module.azurerm_subnet["AksSubnet"].id
	log_analytics_workspace_id = module.azurerm_log_analytics_workspace.log_analytics_workspace_resource_id
	disk_encryption_set_id     = module.azurerm_disk_encryption_set_linux_vm.disk_encryption_set_id
	enable_diagnostic          = var.enable_diagnostics
	tags                       = merge(local.common_tags, { ROLE = "AKS" })
}
```

## PCI-Aligned Defaults

- Private cluster enabled.
- Local admin accounts disabled.
- Azure RBAC and Microsoft Entra admin groups required.
- Azure Policy enabled.
- OIDC issuer and workload identity enabled.
- Node public IPs disabled.
- Standard load balancer SKU enforced.
- User-defined routing enabled by default for controlled egress.
- Key Vault Secrets Provider and secret rotation enabled.
- Image cleaner enabled.
- Autoscaling enabled for the default system node pool.

Set `default_node_pool_host_encryption_enabled` and `default_node_pool_fips_enabled` to `true` only after confirming the subscription features, VM sizes, and OS images support them in the target region.
