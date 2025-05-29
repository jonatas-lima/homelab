variable "traefik_config" {
  type = object({
    version = optional(string, "v3.3")
  })
  default = {}
}

# data "http" "traefik_rbac_manifest" {
#   url = "https://raw.githubusercontent.com/traefik/traefik/${var.traefik_config.version}/docs/content/reference/dynamic-configuration/kubernetes-gateway-rbac.yml"
# }

# locals {
#   _traefik_rbac_resources_list = split("---", data.http.traefik_rbac_manifest.response_body)
#   traefik_rbac_resources_list = {
#     for resource in slice(local._traefik_rbac_resources_list, 1, length(local._traefik_rbac_resources_list)) :
#     "${yamldecode(resource)["apiVersion"]}_${yamldecode(resource)["kind"]}" => yamldecode(replace(resource, "/(?s:\nstatus:.*)$/", ""))
#   }
# }

# resource "kubernetes_manifest" "traefik_rbac" {
#   for_each = local.traefik_rbac_resources_list

#   manifest = each.value
# }

module "traefik_rbac" {
  source = "../modules/raw-kubernetes-manifest"

  url = "https://raw.githubusercontent.com/traefik/traefik/${var.traefik_config.version}/docs/content/reference/dynamic-configuration/kubernetes-gateway-rbac.yml"
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

  values = [templatefile("./values/traefik.yaml.tpl", {
    load_balancer_ip = "10.190.10.105"
  })]
}
