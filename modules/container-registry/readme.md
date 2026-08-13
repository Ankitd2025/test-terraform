# Azure Container Registry Module

This Terraform module creates an Azure Container Registry with optional geo-replication. Geo-replication is controlled by the `geo_replications` variable and is not created unless one or more replication locations are provided.

## Features

- Creates an Azure Container Registry.
- Supports Basic, Standard, and Premium SKUs.
- Supports optional admin access.
- Supports optional public network access, quarantine policy, zone redundancy, anonymous pull, and dedicated data endpoints.
- Supports optional geo-replication using a list of replication regions.

## Usage

### Container Registry without Geo-Replication

```hcl
module "container_registry" {
	source = "../../modules/container-registry"

	name                = "acrmyappprd001"
	resource_group_name = "rg-myapp-prd-001"
	location            = "eastus"
	sku                 = "Premium"
	admin_enabled       = false

	tags = {
		Environment = "prd"
		Workload    = "myapp"
	}
}
```

### Container Registry with Geo-Replication

```hcl
module "container_registry" {
	source = "../../modules/container-registry"

	name                = "acrmyappprd001"
	resource_group_name = "rg-myapp-prd-001"
	location            = "eastus"
	sku                 = "Premium"
	admin_enabled       = false

	geo_replications = [
		{
			location                  = "westus"
			regional_endpoint_enabled = true
			zone_redundancy_enabled   = false
		},
		{
			location                  = "centralus"
			regional_endpoint_enabled = true
			zone_redundancy_enabled   = true
		}
	]

	tags = {
		Environment = "prd"
		Workload    = "myapp"
	}
}
```

## Important Notes

- Azure Container Registry geo-replication requires the `Premium` SKU.
- Leave `geo_replications = []` or omit it to create the registry without geo-replication.
- Registry names must be globally unique and contain only alphanumeric characters.

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `name` | The name of the Container Registry. | `string` | n/a |
| `resource_group_name` | The name of the resource group in which to create the Container Registry. | `string` | n/a |
| `location` | The Azure region where the Container Registry will be created. | `string` | n/a |
| `sku` | The SKU of the Container Registry. | `string` | `"Premium"` |
| `admin_enabled` | Whether the admin user is enabled. | `bool` | `false` |
| `public_network_access_enabled` | Whether public network access is enabled. | `bool` | `true` |
| `quarantine_policy_enabled` | Whether quarantine policy is enabled. | `bool` | `false` |
| `zone_redundancy_enabled` | Whether zone redundancy is enabled. | `bool` | `false` |
| `anonymous_pull_enabled` | Whether anonymous pull access is enabled. | `bool` | `false` |
| `data_endpoint_enabled` | Whether dedicated data endpoints are enabled. | `bool` | `false` |
| `geo_replications` | Optional geo-replication locations. | `list(object)` | `[]` |
| `tags` | A map of tags to assign to the Container Registry. | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `container_registry_id` | The ID of the Container Registry. |
| `container_registry_name` | The name of the Container Registry. |
| `container_registry_login_server` | The login server URL of the Container Registry. |
| `container_registry_admin_username` | The admin username when admin access is enabled. |
