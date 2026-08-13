output "kubernetes_cluster_node_pool_id" {
	description = "The ID of the AKS user node pool."
	value       = azurerm_kubernetes_cluster_node_pool.azurerm_kubernetes_cluster_node_pool.id
}

output "kubernetes_cluster_node_pool_name" {
	description = "The name of the AKS user node pool."
	value       = azurerm_kubernetes_cluster_node_pool.azurerm_kubernetes_cluster_node_pool.name
}

output "kubernetes_cluster_node_pool_node_image_version" {
	description = "The node image version running on the AKS user node pool."
	value       = azurerm_kubernetes_cluster_node_pool.azurerm_kubernetes_cluster_node_pool.node_image_version
}
