resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "8.2.7"
  namespace  = kubernetes_namespace_v1.argocd.id
  name       = "argocd"

  values = [templatefile("./values/argocd.yaml", {})]
}

# resource "helm_release" "argocd_gateway" {

# }
