variable "cert_manager_config" {
  type = object({
    namespace                   = optional(string, "cert-manager")
    version                     = optional(string, "v1.15.3")
    dns01_recursive_nameservers = optional(string, "8.8.8.8:53,1.1.1.1:53")
    controller = optional(object({
      replica_count = optional(number, 3)
      resources = optional(object({
        requests = optional(object({
          cpu    = optional(string, "20m")
          memory = optional(string, "128Mi")
        }), {})
        limits = optional(object({
          cpu    = optional(string, "100m")
          memory = optional(string, "256Mi")
        }), {})
      }), {})
    }), {})
    webhook = optional(object({
      replica_count = optional(number, 3)
      resources = optional(object({
        requests = optional(object({
          cpu    = optional(string, "10m")
          memory = optional(string, "64Mi")
        }), {})
        limits = optional(object({
          cpu    = optional(string, "100m")
          memory = optional(string, "128Mi")
        }), {})
      }), {})
    }), {})
    cainjector = optional(object({
      replica_count = optional(number, 3)
      resources = optional(object({
        requests = optional(object({
          cpu    = optional(string, "20m")
          memory = optional(string, "320Mi")
        }), {})
        limits = optional(object({
          cpu    = optional(string, "100m")
          memory = optional(string, "512Mi")
        }), {})
      }), {})
    }), {})
  })
  default = {}
}

resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name       = local.helm_charts.cert_manager.release_name
  chart      = local.helm_charts.cert_manager.chart
  repository = local.helm_charts.cert_manager.repository
  namespace  = kubernetes_namespace_v1.cert_manager.id

  values = [templatefile("./values/cert-manager.yaml.tpl", {
    controller = var.cert_manager_config.controller
    webhook    = var.cert_manager_config.webhook
    cainjector = var.cert_manager_config.cainjector
  })]
}
