locals {
  helm_charts = {
    ceph_csi_rbd = {
      release_name = "ceph-csi-rbd"
      chart        = "ceph-csi-rbd"
      repository   = "https://ceph.github.io/csi-charts"
    }

    cilium = {
      release_name = "cilium"
      chart        = "cilium"
      repository   = "https://helm.cilium.io/"
    }

    metallb = {
      release_name = "metallb"
      chart        = "metallb"
      repository   = "https://metallb.github.io/metallb"
    }

    velero = {
      release_name = "velero"
      chart        = "velero"
      repository   = "https://vmware-tanzu.github.io/helm-charts"
    }

    coredns = {
      release_name = "coredns"
      chart        = "coredns"
      repository   = "https://coredns.github.io/helm"
    }

    metrics_server = {
      release_name = "metrics-server"
      chart        = "metrics-server"
      repository   = "https://kubernetes-sigs.github.io/metrics-server"
    }

    vault_secrets_operator = {
      release_name = "vault-secrets-operator"
      chart        = "vault-secrets-operator"
      repository   = "https://helm.releases.hashicorp.com"

    }

    cert_manager = {
      release_name = "cert-manager"
      chart        = "cert-manager"
      repository   = "https://charts.jetstack.io"

      kubernetes_intermediate_ca_path = "pki-mgc-k8s-intermediate-ca-${terraform.workspace}"

      cert_ttl          = "157680000" # 5 years
      cert_sign_backend = "pki-mgc-intermediate-ca"

      cert_pki_ttl  = 7776000 # 3 months
      cert_pki_size = 4096

      vault_kubernetes_auth_role_name      = "cert-manager"
      vault_kubernetes_auth_backend_name   = "kubernetes-cert-manager-${terraform.workspace}"
      vault_kubernetes_cluster_issuer_name = "vault"
      vault_kubernetes_issuer              = "https://kubernetes.default.svc.cluster.local"
    }

    trust_manager = {
      release_name = "trust-manager"
      chart        = "trust-manager"
      repository   = "https://charts.jetstack.io"
    }

    external_dns = {
      chart        = "external-dns"
      release_name = "external-dns"
      repository   = "https://kubernetes-sigs.github.io/external-dns/"
    }

    raw_manifest = {
      chart      = "raw"
      version    = "0.3.2"
      repository = "https://dysnix.github.io/charts"
    }

    logging_operator = {
      chart      = "logging-operator"
      repository = "oci://ghcr.io/kube-logging/helm-charts"
    }
  }
}
