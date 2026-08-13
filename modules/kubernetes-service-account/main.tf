resource "kubernetes_service_account_v1" "kubernetes_service_account_v1" {
  metadata {
    name      = var.name
    namespace = var.namespace
    annotations = {
      "azure.workload.identity/client-id" = var.client_id
    }
  }
}
