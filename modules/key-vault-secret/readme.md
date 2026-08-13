# Azure Key Vault Secret Module

This module creates an Azure Key Vault secret.

Use it for generated or externally supplied secret values that must be stored in Key Vault. The `value` input is marked sensitive, but Terraform-managed secret values are still stored in Terraform state.
