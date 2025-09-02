variable "vault_address" {
  type    = string
  default = "https://vault.uzbunitim.me:8200"
}

variable "kubeconfig_path" {
  type        = string
  default     = "/tmp/kubeconfig.yml"
  description = "Path to the Kubeconfig file."
}

variable "external_secrets_config" {
  type = object({
    namespace = optional(string, "external-secrets")
    version   = optional(string, "0.18.2")
    vault_config = optional(object({
      mount = optional(string, "kubernetes-secrets")
      auth = optional(object({
        mount_path = optional(string, "kubernetes")
        role_name  = optional(string, "external-secrets")
      }), {})
    }), {})
  })
  default = {}
}

locals {
  kubeconfig         = yamldecode(file(var.kubeconfig_path))
  kubernetes_ca_cert = base64decode(local.kubeconfig.clusters[0].cluster.certificate-authority-data)
  kubernetes_server  = local.kubeconfig.clusters[0].cluster.server
}

resource "kubernetes_namespace_v1" "external_secrets" {
  metadata {
    name = var.external_secrets_config.namespace
  }
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  chart      = local.helm_charts.external_secrets_operator.chart
  repository = local.helm_charts.external_secrets_operator.repository
  namespace  = kubernetes_namespace_v1.external_secrets.id
  version    = var.external_secrets_config.version

  values = [
    templatefile("./values/external_secrets.yaml.tftpl", {
      log_level     = "info"
      replica_count = 1
    })
  ]
}

resource "kubernetes_service_account_v1" "external_secrets" {
  metadata {
    name      = "external-secrets-vault"
    namespace = kubernetes_namespace_v1.external_secrets.id
  }
}

resource "kubernetes_secret_v1" "external_secrets_token" {
  metadata {
    name      = "${kubernetes_service_account_v1.external_secrets.metadata[0].name}-token"
    namespace = kubernetes_namespace_v1.external_secrets.id
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.external_secrets.metadata[0].name
    }
  }
  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

module "external_secrets_vault_authentication" {
  depends_on = [kubernetes_secret_v1.external_secrets_token]

  source = "../modules/kubernetes-vault-authentication"

  kubernetes_config    = local.kubernetes_config
  service_account_name = kubernetes_service_account_v1.external_secrets.metadata[0].name
  namespace            = kubernetes_namespace_v1.external_secrets.id
  role_name            = var.external_secrets_config.vault_config.auth.role_name
  vault_mount          = var.external_secrets_config.vault_config.mount
  vault_address        = var.vault_address
  policies             = [vault_policy.external_secrets_operator.name]
}

resource "vault_policy" "external_secrets_operator" {
  name   = "external-secrets-operator"
  policy = <<-EOT
path "${var.external_secrets_config.vault_config.mount}/data/*" {
  capabilities = ["read"]
}
  EOT
}

data "terraform_remote_state" "infra" {
  backend = "local"
  config = {
    path = "../002-infra-services/terraform.tfstate"
  }
}

resource "helm_release" "secret_store" {
  name       = "vault-secret-store"
  namespace  = kubernetes_namespace_v1.external_secrets.id
  chart      = local.helm_charts.raw_manifest.chart
  version    = local.helm_charts.raw_manifest.version
  repository = local.helm_charts.raw_manifest.repository

  values = [
    yamlencode({
      resources = [
        {
          apiVersion = "external-secrets.io/v1"
          kind       = "ClusterSecretStore"
          metadata = {
            name = "vault-secret-store"
          }
          spec = {
            provider = {
              vault = {
                server   = var.vault_address
                path     = var.external_secrets_config.vault_config.mount
                version  = "v2"
                caBundle = data.terraform_remote_state.infra.outputs.vault_certs["vault-ca.pem"]
                auth = {
                  kubernetes = {
                    mountPath = var.external_secrets_config.vault_config.auth.mount_path
                    role      = var.external_secrets_config.vault_config.auth.role_name
                    serviceAccountRef = {
                      audiences = ["vault"]
                      name      = kubernetes_service_account_v1.external_secrets.metadata[0].name
                      namespace = kubernetes_namespace_v1.external_secrets.id
                    }
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

# apiVersion: external-secrets.io/v1
# kind: ClusterSecretStore
# metadata:
#   name: vault-backend
# spec:
#   provider:
#     vault:
#       server: "https://vault.uzbunitim.me:8200"
#       path: "kubernetes-secrets"
#       # Version is the Vault KV secret engine version.
#       # This can be either "v1" or "v2", defaults to "v2"
#       version: "v2"

#       caBundle: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUYvakNDQSthZ0F3SUJBZ0lSQVBYcnRSTXF4UUx5elJ2UHRIemN5YVF3RFFZSktvWklodmNOQVFFTEJRQXcKY2pFTE1Ba0dBMVVFQmhNQ1FsSXhDekFKQmdOVkJBZ1RBbEJDTVJjd0ZRWURWUVFIRXc1RFlXMXdhVzVoSUVkeQpZVzVrWlRFU01CQUdBMVVFQ2hNSmRYcGlkVzVwZEdsdE1SRXdEd1lEVlFRTEV3aFdZWFZzZENCRFFURVdNQlFHCkExVUVBeE1OVm1GMWJIUWdVbTl2ZENCRFFUQWVGdzB5TlRBNE1ESXhORFEwTlRSYUZ3MHpOVEEzTXpFeE5EUTAKTlRSYU1ISXhDekFKQmdOVkJBWVRBa0pTTVFzd0NRWURWUVFJRXdKUVFqRVhNQlVHQTFVRUJ4TU9RMkZ0Y0dsdQpZU0JIY21GdVpHVXhFakFRQmdOVkJBb1RDWFY2WW5WdWFYUnBiVEVSTUE4R0ExVUVDeE1JVm1GMWJIUWdRMEV4CkZqQVVCZ05WQkFNVERWWmhkV3gwSUZKdmIzUWdRMEV3Z2dJaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQ0R3QXcKZ2dJS0FvSUNBUURna0lwelNNSEs2UFNKRzhQU3dkRExYcXpzUU96b1FJVDNjUldVLzFxYStzOHJRU0kyWXFFcgpIM1JFWnBKTTJCTlA3eXlZem5pdERnMmV2K1hGTDZES29QOUxCUXpSMi9JcVJQbk9zMnVJb0trYVg3NlVDWHdiCnJHbThDZjNlZENiTWZiaHlNOWdRVnV5dytrWEhqdUVTZjFlYWJDeW5YWnhkeVNxNlVGR3hjdFV2aXVLaEwyb2EKMGpmQW9sam5GK1BUSGhSWmNjbWFScGoxeE96eWw0Vi82eXh1RVBHbHpBWWZsK2orM1FPMW12RUpqaHhhQ25jdwoxc1AyTkEwcnJzcVJDOFNqSWFPWkNCWjdkRjl4dVZHbWdxcDVEZ0wzeTlOelA5OU5weG84OEtnVC8vVVZQTUNBCi94Nm02ZG9mUkpISGdJZXBLeUFoNEkyd0w0SGxUVitBcVBBcHptMnJhcUg0VnNNSjd2WUcxL2VSdzhFczZHSlAKN2U1Z0VBWk80MVRRc0VTRE1XNWFjVnZDdlpiL2V0cXBpRW41bGhHUGlmMm5oOGU1TEhQTk9nT3VmKzFFYVVDZgphdm5nbzgxdG54NlZWZnZrcWJGTTMwamRSMmdTM1Y2bUZwM3pOSCtOUmt2R1BkeWkwY2tUU3RvVmF6UVIzcE50CnQzS3NTbjNORjVzN1F3OHYwUkh0MmFXT0IxWnJDR3lZLzFlRDZRT0FncnJFLzdOc2pXVDg0elVHQ0pRY1VqV2MKTUFDTzErYTNGVnFCeFlaMmZkQjN0aXpTRXRyL2haUTVQM29YZG14Y2w1VUtydlZzcDVjemcxVTNhR1RWNFNZawpHVVNXbGJuVTdVZ1QyWDJXYjBlamVZY3VPSnhzbmxvbVpYNERGWnhhc280WGo5NGVxVmpVT3dJREFRQUJvNEdPCk1JR0xNQTRHQTFVZER3RUIvd1FFQXdJQnBqQVRCZ05WSFNVRUREQUtCZ2dyQmdFRkJRY0RBVEFQQmdOVkhSTUIKQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJUNFJLV2lrV1Z3NXRZK01PMWRBVHZlQTU2TzhUQTBCZ05WSFJFRQpMVEFyZ2dsc2IyTmhiR2h2YzNTQ0VuWmhkV3gwTG5WNlluVnVhWFJwYlM1dFpZY0Vmd0FBQVljRUNyNExDakFOCkJna3Foa2lHOXcwQkFRc0ZBQU9DQWdFQVB6bGtlMm1yc3pYL3dzYmNXYWdyVDJxNkR4ZnRkRnlWTEZoamF5dVMKbjZzQWtjLzlNcHNndGk3NXphR1ZuMm9MS1ZtMHRwYThaTU50dTFka2M2ZzM1cDVrVk41TllaMWQzVzNkMzBITwp5a1hybzZOeWJLdFErYmNiMkw2emd3VVFybkRQV0V4RHVmdFRBZzdKeERsYTJCSU03cndDWFUwZm9NdjdYTjcxCm9mbldWRzFQVzFOMmdlZmpLbWc5YTg1amY1eHg4endIL0xYdzUvL2oydE1ROG9VcWhKMzRMYnlwMi9odUUxNFMKak1oUy8xbnVKOEpJUTBlSm5RcE15NEVrRENGdWRBalljZEgwcW5CYmhKbVc4aEZ1ZG1LdTU3ZEVmYklDdndWWgpuYnNXbnIweUxNOG1iS0JPMWRVS3JSNzltK2pRVTdaREtrRjhGOTdCTXpEY2pzMGp0UUNaZmdoSHFPSVdPQWpjCnFJMDdBZ2lqTkJQNlVDRFArOHc0eC8vRUsxSjRpL0R3bTg0U05lYU9PMW50V1lWci84VURpUWJmNWQwZG9FaEoKT0FFdGE4WlIvVFp3NFQ5Rm5QNkF5NmdkdWRkNHEwbCtrYjJRaW45b2lxempaMUg3K3FaUEpHN1lmaEdydVpjYwphL2x6TGM0RlBheW9HTzVuTzdqdGRQWENWN2pQMkhLaWxjb2krOTMyRTRSM1VmSXFmL3gzMXNxZ0dQMXZ0REtCCkUwL3EzbWNOUFE1K2JKMnhvWVB4aUgwa1AwNUNDdEZoNkJhZkZOT3FnZkZVMXNaeE53S1ZlYTJBb1dqdHNJV2IKODd5ZisvRlBXajlYL0NjeDBlWmdOcHI5Q21CbElnSUdmNEIvVVdkaWkvK2d3cm1wRE5UYmlOdndBUFpsajhoZwpsdzQ9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
#       auth:
#         kubernetes:
#           mountPath: kubernetes
#           role: external-secrets
#           serviceAccountRef:
#             audiences: [vault]
#             name: external-secrets-vault
#             namespace: external-secrets
