locals {
  bitnami_repository = "https://charts.bitnami.com/bitnami"

  kubernetes_config = {
    host    = local.kubernetes_server
    ca_cert = local.kubernetes_ca_cert
  }

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

    external_secrets_operator = {
      release_name = "external-secrets"
      chart        = "external-secrets"
      repository   = "https://charts.external-secrets.io"
    }

    cert_manager = {
      release_name = "cert-manager"
      chart        = "cert-manager"
      repository   = "https://charts.jetstack.io"
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
