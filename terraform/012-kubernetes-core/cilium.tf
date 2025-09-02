variable "cilium_config" {
  description = "Configuration for Cilium, an eBPF-based networking platform."

  type = object({
    namespace = optional(string, "kube-system")
    version   = optional(string, "1.18.0")
    mtu       = optional(number, 1430)
    log_level = optional(string, "info")
    ipam = optional(object({
      advertised_ranges = optional(list(object({
        start = string
        stop  = string
      })))
    }), {})
  })
  default = {
    ipam = {
      advertised_ranges = [
        {
          start = "10.191.0.100"
          stop  = "10.191.0.120"
        }
      ]
    }
  }
}

resource "helm_release" "cilium" {
  name       = local.helm_charts.cilium.release_name
  chart      = local.helm_charts.cilium.chart
  repository = local.helm_charts.cilium.repository

  version          = var.cilium_config.version
  namespace        = var.cilium_config.namespace
  create_namespace = true

  values = [templatefile("./values/cilium.yaml.tpl", {
    apiserver_endpoint = split(":", module.common.endpoints.kubernetes[var.project])[0]
    log_level          = var.cilium_config.log_level
    mtu                = var.cilium_config.mtu
  })]
}

resource "helm_release" "cilium_ipam" {
  depends_on = [helm_release.cilium]

  name       = "cilium-ipam"
  chart      = local.helm_charts.raw_manifest.chart
  version    = local.helm_charts.raw_manifest.version
  repository = local.helm_charts.raw_manifest.repository

  values = [
    yamlencode({
      resources = [
        {
          apiVersion = "cilium.io/v2alpha1"
          kind       = "CiliumLoadBalancerIPPool"
          metadata = {
            name      = "default"
            namespace = var.cilium_config.namespace
          }
          spec = {
            blocks = [
              {
                start = "10.191.0.100"
                stop  = "10.191.0.120"
              }
            ]
          }
        },
        {
          apiVersion = "cilium.io/v2alpha1"
          kind       = "CiliumL2AnnouncementPolicy"
          metadata = {
            name      = "default"
            namespace = var.cilium_config.namespace
          }
          spec = {
            externalIPs     = true
            loadBalancerIPs = true
          }
        }
      ]
    })
  ]
}
