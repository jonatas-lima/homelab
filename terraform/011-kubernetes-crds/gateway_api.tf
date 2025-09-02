variable "gateway_api_config" {
  description = "Configuration for the Kubernetes Gateway API CRDs installation."
  type = object({
    version = optional(string, "v1.2.0")
  })
  default = {}
}

module "gateway_api" {
  source = "../modules/raw-kubernetes-manifest"

  name = "gateway-api-crds"
  url  = "https://github.com/kubernetes-sigs/gateway-api/releases/download/${var.gateway_api_config.version}/standard-install.yaml"
}
