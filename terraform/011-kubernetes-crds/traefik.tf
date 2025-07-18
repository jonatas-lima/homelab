variable "traefik_config" {
  description = "Configuration for Traefik RBAC resources required for Gateway API integration."
  type = object({
    version = optional(string, "v3.3")
  })
  default = {}
}

module "traefik_rbac" {
  source = "../modules/raw-kubernetes-manifest"

  url = "https://raw.githubusercontent.com/traefik/traefik/${var.traefik_config.version}/docs/content/reference/dynamic-configuration/kubernetes-gateway-rbac.yml"
}
