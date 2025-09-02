variable "kubernetes_config" {
  description = "Kubernetes cluster connection configuration"
  type = object({
    ca_cert = string
    host    = string
  })
}

variable "vault_auth_backend" {
  description = "Vault Kubernetes auth backend name"
  type        = string
  default     = "kubernetes"
}

variable "role_name" {
  description = "Name of the Vault Kubernetes auth role"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the service account"
  type        = string
}

variable "service_account_name" {
  description = "Name of the Kubernetes service account"
  type        = string
}

variable "policies" {
  description = "List of Vault policies to attach to the role"
  type        = list(string)
  default     = []
}

data "kubernetes_secret_v1" "service_account_token" {
  metadata {
    name      = "${var.service_account_name}-token"
    namespace = var.namespace
  }
}

resource "vault_kubernetes_auth_backend_config" "this" {
  backend                = var.vault_auth_backend
  kubernetes_host        = var.kubernetes_config.host
  token_reviewer_jwt     = data.kubernetes_secret_v1.service_account_token.data.token
  kubernetes_ca_cert     = var.kubernetes_config.ca_cert
  disable_iss_validation = true
}

resource "vault_kubernetes_auth_backend_role" "this" {
  backend                          = var.vault_auth_backend
  role_name                        = var.role_name
  bound_service_account_names      = [var.service_account_name]
  bound_service_account_namespaces = [var.namespace]
  token_policies                   = var.policies
  audience                         = "vault"
  token_ttl                        = 3600 # 1h
}

resource "kubernetes_cluster_role_binding_v1" "token_reviewer" {
  metadata {
    name = "${var.service_account_name}-token-reviewer"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.service_account_name
    namespace = var.namespace
  }
}
