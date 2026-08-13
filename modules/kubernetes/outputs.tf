output "kubernetes_cluster_id" {
  description = "The ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.azurerm_kubernetes_cluster.id
}

output "kubernetes_cluster_name" {
  description = "The name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.azurerm_kubernetes_cluster.name
}

output "kubernetes_cluster_host" {
  description = "The Kubernetes API server host from kube config."
  value       = azurerm_kubernetes_cluster.azurerm_kubernetes_cluster.kube_config[0].host
  sensitive   = true
}

output "kubernetes_cluster_cluster_ca_certificate" {
  description = "The cluster CA certificate from kube config (base64)."
  value       = azurerm_kubernetes_cluster.azurerm_kubernetes_cluster.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

output "kubernetes_cluster_fqdn" {
  description = "The private FQDN of the AKS cluster."
  value       = azurerm_kubernetes_cluster.azurerm_kubernetes_cluster.private_fqdn
}

output "kubernetes_cluster_kubelet_identity_object_id" {
  description = "The object ID of the AKS kubelet identity."
  value       = azurerm_kubernetes_cluster.azurerm_kubernetes_cluster.kubelet_identity[0].object_id
}

output "kubernetes_cluster_identity_principal_id" {
  description = "The principal ID of the AKS control plane identity."
  value       = azurerm_kubernetes_cluster.azurerm_kubernetes_cluster.identity[0].principal_id
}

output "kubernetes_cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for workload identity."
  value       = azurerm_kubernetes_cluster.azurerm_kubernetes_cluster.oidc_issuer_url
}

output "kubernetes_cluster_node_resource_group" {
  description = "The auto-generated node resource group used by AKS."
  value       = azurerm_kubernetes_cluster.azurerm_kubernetes_cluster.node_resource_group
}
