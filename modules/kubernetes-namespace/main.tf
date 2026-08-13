resource "kubernetes_namespace_v1" "kubernetes_namespace_v1" {
  metadata {
    name = var.name
  }
}
