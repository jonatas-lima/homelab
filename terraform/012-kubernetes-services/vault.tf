resource "kubernetes_namespace_v1" "vault" {
  metadata {
    name = "vault"
  }
}

resource "helm_release" "vault" {
  name       = "vault"
  chart      = "vault"
  repository = "https://helm.releases.hashicorp.com"
  version    = "0.30.0"
  namespace  = kubernetes_namespace_v1.vault.id

  values = [templatefile("./values/vault.yaml.tftpl", {})]
}
