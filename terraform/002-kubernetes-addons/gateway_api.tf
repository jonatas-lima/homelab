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

resource "kubernetes_namespace_v1" "internal_gateway" {
  metadata {
    name = "internal-gateway"
  }
}

locals {
  internal_gateway_resources = {
    resources = [
      {
        apiVersion = "gateway.networking.k8s.io/v1"
        kind       = "Gateway"
        metadata = {
          name      = "internal-gateway"
          namespace = kubernetes_namespace_v1.internal_gateway.id
        }
        spec = {
          gatewayClassName = "internal"
          listeners = [
            {
              name     = "http"
              protocol = "HTTP"
              port     = 80
            },
            {
              name     = "https"
              protocol = "HTTP"
              port     = 443
            }
          ]
        }
      }
    ]
  }
}

resource "helm_release" "internal_gateway" {
  depends_on = [module.gateway_api]

  namespace  = kubernetes_namespace_v1.internal_gateway.id
  chart      = "raw"
  repository = "https://dysnix.github.io/charts"
  name       = "internal-gateway"
  version    = "0.3.2"

  values = [yamlencode(local.internal_gateway_resources)]
}
