variable "traefik_config" {
  description = "Configuration for Traefik, a HTTP reverse proxy and load balancer."

  type = object({
    version = optional(string, "v35.4.0")
  })
  default = {}
}

resource "kubernetes_namespace_v1" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik" {
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  name       = "traefik"
  namespace  = kubernetes_namespace_v1.traefik.id
  version    = var.traefik_config.version

  values = [templatefile("./values/traefik.yaml.tpl", {
    load_balancer_ip = "10.191.0.120"
  })]
}
