# Environment specific local variables for the Hub environment
locals {
  project_name = var.project_name
  env          = var.env
  region_code  = var.region_code
  region       = var.region
  instance     = var.instance

  # Common tags for all resources in the Hub environment
  common_tags = merge(var.tags, {
    ENVIRONMENT = upper(var.env)
    PROJECT     = upper(var.project_name)
    MANAGEDBY  = "TERRAFORM"
  })

  # Naming convention following Azure best practices
  resources_name_suffix = "${local.project_name}-${local.env}-${local.region_code}-${local.instance}"
}