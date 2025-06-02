variable "gateway_api_config" {
  type = object({
    version = optional(string, "v1.2.0")
  })
  default = {}
}

module "gateway_api" {
  source = "../modules/raw-kubernetes-manifest"

  url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/${var.gateway_api_config.version}/standard-install.yaml"
}
