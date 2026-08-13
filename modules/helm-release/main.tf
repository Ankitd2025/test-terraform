resource "helm_release" "helm_release" {
  name       = var.name
  namespace  = var.namespace
  repository = var.repository
  chart      = var.chart
  version    = var.chart_version
  values     = [yamlencode(var.set_values)]
}
