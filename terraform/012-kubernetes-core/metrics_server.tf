resource "helm_release" "metrics_server" {
  name       = local.helm_charts.metrics_server.release_name
  chart      = local.helm_charts.metrics_server.chart
  repository = local.helm_charts.metrics_server.repository
  namespace  = "kube-system"
}
