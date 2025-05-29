variable "cilium_config" {
  type = object({
    namespace = optional(string, "kube-system")
    version   = optional(string, "1.17.2")
    mtu       = optional(number, 1430)
    log_level = optional(string, "info")
  })
  default = {}
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
    # hubble_ui_fqdn     = local.helm_charts.cilium.hubble_ui_fqdn
  })]
}
