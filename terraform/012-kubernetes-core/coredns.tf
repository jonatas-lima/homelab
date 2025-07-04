variable "coredns_config" {
  description = "Configuration for CoreDNS."

  type = object({
    namespace = optional(string, "kube-system")
    version   = optional(string, "1.39.2")

    autoscaler = optional(object({
      enabled           = optional(bool, true)
      cores_per_replica = optional(number, 32)
      nodes_per_replica = optional(number, 2)
      min               = optional(number, 5)
      max               = optional(number, 0)
    }), {})

    cache_duration     = optional(number, 30)
    additional_plugins = optional(list(map(any)), [])
  })
  default = {
    autoscaler = {
      enabled = false
    }
  }
}

resource "helm_release" "coredns" {
  name       = local.helm_charts.coredns.release_name
  chart      = local.helm_charts.coredns.chart
  repository = local.helm_charts.coredns.repository

  version   = var.coredns_config.version
  namespace = var.coredns_config.namespace

  values = [templatefile("./values/coredns.yaml.tpl", {
    autoscaler         = var.coredns_config.autoscaler
    cache_duration     = var.coredns_config.cache_duration
    additional_plugins = var.coredns_config.additional_plugins
  })]
}
