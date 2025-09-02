resource "kubernetes_service_account_v1" "this" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace
  }
}

resource "kubernetes_secret_v1" "service_account_token" {
  metadata {
    name      = "${var.service_account_name}-sat"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.this.metadata[0].name
    }
  }
  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

resource "kubernetes_role_v1" "vault_cluster_issuer_token_create" {
  metadata {
    name      = var.issuer_name
    namespace = var.namespace
  }

  rule {
    api_groups = [""]
    resources  = ["serviceaccounts/token"]
    resource_names = [
      kubernetes_service_account_v1.this.metadata[0].name,
    ]
    verbs = ["create"]
  }
}

resource "kubernetes_role_binding_v1" "vault_cluster_issuer_token_create" {
  metadata {
    name      = var.issuer_name
    namespace = var.namespace
  }

  subject {
    kind      = "ServiceAccount"
    name      = "cert-manager"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.vault_cluster_issuer_token_create.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding_v1" "vault_cluster_issuer" {
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
    name      = kubernetes_service_account_v1.this.metadata[0].name
    namespace = var.namespace
  }
}
