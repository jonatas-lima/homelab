variable "cert_manager_config" {
  description = "Configuration for cert-manager, the certificate management system for Kubernetes."
  type = object({
    namespace                   = optional(string, "cert-manager")
    version                     = optional(string, "v1.15.3")
    dns01_recursive_nameservers = optional(string, "8.8.8.8:53,1.1.1.1:53")

    controller = optional(object({
      replica_count = optional(number, 2)
      resources = optional(object({
        requests = optional(object({
          cpu    = optional(string, "20m")
          memory = optional(string, "128Mi")
        }), {})
        limits = optional(object({
          cpu    = optional(string, "100m")
          memory = optional(string, "256Mi")
        }), {})
      }), {})
    }), {})

    webhook = optional(object({
      replica_count = optional(number, 2)
      resources = optional(object({
        requests = optional(object({
          cpu    = optional(string, "10m")
          memory = optional(string, "64Mi")
        }), {})
        limits = optional(object({
          cpu    = optional(string, "100m")
          memory = optional(string, "128Mi")
        }), {})
      }), {})
    }), {})

    cainjector = optional(object({
      replica_count = optional(number, 2)
      resources = optional(object({
        requests = optional(object({
          cpu    = optional(string, "20m")
          memory = optional(string, "320Mi")
        }), {})
        limits = optional(object({
          cpu    = optional(string, "100m")
          memory = optional(string, "512Mi")
        }), {})
      }), {})
    }), {})
  })
  default = {}
}

variable "vault_pki_issuer_config" {
  type = object({
    mount                = optional(string, "pki-kubernetes")
    role_name            = optional(string, "cert-manager")
    allowed_domains      = optional(list(string), ["uzbunitim.me", "svc.cluster.local", "cluster.local", "local"])
    service_account_name = optional(string, "vault-cluster-issuer")
    auth_backend         = optional(string, "kubernetes")
  })
  default = {}
}

resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name       = local.helm_charts.cert_manager.release_name
  chart      = local.helm_charts.cert_manager.chart
  repository = local.helm_charts.cert_manager.repository
  namespace  = kubernetes_namespace_v1.cert_manager.id

  values = [templatefile("./values/cert-manager.yaml.tpl", {
    controller = var.cert_manager_config.controller
    webhook    = var.cert_manager_config.webhook
    cainjector = var.cert_manager_config.cainjector
  })]
}

resource "vault_mount" "pki" {
  type = "pki"
  path = var.vault_pki_issuer_config.mount

  max_lease_ttl_seconds = 7776000
}

module "vault_pki_auth" {
  source = "../modules/kubernetes-vault-pki"

  vault_address        = var.vault_address
  role_name            = var.vault_pki_issuer_config.role_name
  allowed_domains      = var.vault_pki_issuer_config.allowed_domains
  kubernetes_config    = local.kubernetes_config
  namespace            = kubernetes_namespace_v1.cert_manager.id
  signer_name          = module.common.vault.pki.intermediate_mount
  service_account_name = var.vault_pki_issuer_config.service_account_name
  vault_auth_backend   = var.vault_pki_issuer_config.auth_backend
  ttl                  = 60 * 60 * 24 * 30 * 3
  vault_mount          = vault_mount.pki.path
}

resource "helm_release" "vault_cluster_issuer" {
  name       = "vault-cluster-issuer"
  chart      = local.helm_charts.raw_manifest.chart
  repository = local.helm_charts.raw_manifest.repository
  version    = local.helm_charts.raw_manifest.version
  namespace  = kubernetes_namespace_v1.cert_manager.id

  values = [
    yamlencode({
      resources = [
        {
          apiVersion = "cert-manager.io/v1"
          kind       = "ClusterIssuer"
          metadata = {
            name      = "vault"
            namespace = kubernetes_namespace_v1.cert_manager.id
          }
          spec = {
            vault = {
              path     = "${vault_mount.pki.path}/sign/${var.vault_pki_issuer_config.role_name}"
              server   = var.vault_address
              caBundle = data.terraform_remote_state.infra.outputs.vault_certs["vault-ca.pem"]
              auth = {
                kubernetes = {
                  role      = var.vault_pki_issuer_config.role_name
                  mountPath = "/v1/auth/${var.vault_pki_issuer_config.auth_backend}"
                  serviceAccountRef = {
                    name = var.vault_pki_issuer_config.service_account_name
                  }
                }
              }
            }
          }
        }
      ]
    })
  ]
}
