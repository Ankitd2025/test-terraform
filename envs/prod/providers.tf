
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # # Backend configuration for state management
  backend "azurerm" {
    # Configure in backend-config file per environment
  }
}

provider "azurerm" {
  features {}
  alias               = "hub"
  subscription_id     = var.hub_subscription_id
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }

    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  storage_use_azuread = true
  subscription_id     = var.subscription_id
}

provider "kubernetes" {
  host                   = module.azurerm_kubernetes_cluster.kubernetes_cluster_host
  cluster_ca_certificate = base64decode(module.azurerm_kubernetes_cluster.kubernetes_cluster_cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args        = ["get-token", "--login", "azurecli", "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.azurerm_kubernetes_cluster.kubernetes_cluster_host
    cluster_ca_certificate = base64decode(module.azurerm_kubernetes_cluster.kubernetes_cluster_cluster_ca_certificate)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args        = ["get-token", "--login", "azurecli", "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
    }
  }
}
