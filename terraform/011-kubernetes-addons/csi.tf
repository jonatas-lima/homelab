resource "kubernetes_namespace_v1" "local_path_provisioner" {
  metadata {
    name = "local-path-provisioner"
  }
}

resource "helm_release" "local_path_provisioner" {
  name      = "local-path-provisioner"
  chart     = "./charts/local-path-provisioner"
  namespace = kubernetes_namespace_v1.local_path_provisioner.id
}
