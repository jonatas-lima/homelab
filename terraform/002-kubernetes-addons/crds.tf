resource "kubernetes_namespace_v1" "kube_prometheus" {
  metadata {
    name = "kube-prometheus"
  }
}

resource "helm_release" "kube_prometheus_crds" {
  name       = "prometheus-crds"
  namespace  = kubernetes_namespace_v1.kube_prometheus.id
  chart      = local.helm_charts.kube_prometheus.chart
  repository = local.helm_charts.kube_prometheus.repository
  version    = "14.0.0"
}
