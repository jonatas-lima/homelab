locals {
  kube_prometheus = {
    chart      = "prometheus-operator-crds"
    repository = "https://prometheus-community.github.io/helm-charts"
  }
}

resource "kubernetes_namespace_v1" "kube_prometheus" {
  metadata {
    name = "kube-prometheus"
  }
}

resource "helm_release" "kube_prometheus_crds" {
  name       = "prometheus-crds"
  namespace  = kubernetes_namespace_v1.kube_prometheus.id
  chart      = local.kube_prometheus.chart
  repository = local.kube_prometheus.repository
  version    = "14.0.0"
}
