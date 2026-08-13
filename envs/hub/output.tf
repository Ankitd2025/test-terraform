# Ouput for the Resource Group in the Hub Environment
output "resource_group_id" {
  description = "The ID of the Resource Group."
  value       = module.azurerm_resource_group.resource_group_id
}

output "resource_group_name" {
  description = "The name of the Resource Group."
  value       = module.azurerm_resource_group.resource_group_name
}

output "tags" {
  description = "The Tags for the Resource Group."
  value       = local.common_tags
}

# End of outputs for the Resource Group in the Hub environment

# Output for the Subnet in the Hub Environment
output "subnet_ids" {
  description = "The IDs of the Subnets"
  value       = { for k, v in module.azurerm_subnet : k => v.id }
}

output "subnet_names" {
  description = "The Names of the Subnets"
  value       = { for k, v in module.azurerm_subnet : k => v.name }
}
# End of outputs for the Subnet in the Hub environment