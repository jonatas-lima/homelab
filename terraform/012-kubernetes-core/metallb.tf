variable "metallb_config" {
  type = object({
    namespace       = optional(string, "metallb-system")
    log_level       = optional(string, "info")
    version         = optional(string, "0.14.8")
    ip_address_pool = optional(list(string), [])
    controller = optional(object({
      resources = optional(object({
        requests = optional(object({
          cpu    = optional(string, "30m")
          memory = optional(string, "256Mi")
        }), {})
        limits = optional(object({
          cpu    = optional(string, "300m")
          memory = optional(string, "1Gi")
        }), {})
      }), {})
    }), {})
    speaker = optional(object({
      resources = optional(object({
        requests = optional(object({
          cpu    = optional(string, "50m")
          memory = optional(string, "128Mi")
        }), {})
        limits = optional(object({
          cpu    = optional(string, "200m")
          memory = optional(string, "512Mi")
        }), {})
      }), {})
      frr = optional(object({
        resources = optional(object({
          requests = optional(object({
            cpu    = optional(string, "20m")
            memory = optional(string, "128Mi")
          }), {})
          limits = optional(object({
            cpu    = optional(string, "300m")
            memory = optional(string, "512Mi")
          }), {})
        }), {})
      }), {})
      frr_metrics = optional(object({
        resources = optional(object({
          requests = optional(object({
            cpu    = optional(string, "40m")
            memory = optional(string, "96Mi")
          }), {})
          limits = optional(object({
            cpu    = optional(string, "200m")
            memory = optional(string, "512Mi")
          }), {})
        }), {})
      }), {})
      reloader = optional(object({
        resources = optional(object({
          requests = optional(object({
            cpu    = optional(string, "10m")
            memory = optional(string, "32Mi")
          }), {})
          limits = optional(object({
            cpu    = optional(string, "200m")
            memory = optional(string, "128Mi")
          }), {})
        }), {})
      }), {})
    }), {})
  })
  default = {
    ip_address_pool = ["10.191.0.100-10.191.0.120"]
  }
}

resource "kubernetes_namespace_v1" "metallb" {
  metadata {
    name = var.metallb_config.namespace
  }
}

resource "helm_release" "metallb" {
  name       = local.helm_charts.metallb.release_name
  chart      = local.helm_charts.metallb.chart
  repository = local.helm_charts.metallb.repository

  version   = var.metallb_config.version
  namespace = kubernetes_namespace_v1.metallb.id

  values = [templatefile("./values/metallb.yaml.tpl", {
    log_level  = var.metallb_config.log_level
    controller = var.metallb_config.controller
    speaker    = var.metallb_config.speaker
  })]
}

locals {
  ip_pool_manifest = {
    resources = [
      {
        apiVersion = "metallb.io/v1beta1"
        kind       = "IPAddressPool"
        metadata = {
          name      = "lb-pool"
          namespace = kubernetes_namespace_v1.metallb.id
        }
        spec = {
          addresses = var.metallb_config.ip_address_pool
        }
      },
      {
        apiVersion = "metallb.io/v1beta1"
        kind       = "L2Advertisement"
        metadata = {
          name      = "lb-pool-advertisement"
          namespace = kubernetes_namespace_v1.metallb.id
        }
        spec = {
          ipAddressPools = [
            "lb-pool"
          ]
        }
      }
    ]
  }
}

resource "helm_release" "metallb_ipam" {
  depends_on = [helm_release.metallb]

  name       = "metallb-ipam"
  namespace  = kubernetes_namespace_v1.metallb.id
  repository = local.helm_charts.raw_manifest.repository
  chart      = local.helm_charts.raw_manifest.chart
  version    = local.helm_charts.raw_manifest.version

  values = [yamlencode(local.ip_pool_manifest)]
}
