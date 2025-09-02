# Kubernetes Core

This project installs and configures core Kubernetes components and operators.

## Stack

- Cilium (CNI)
- Traefik (Ingress Controller)
- Cert-Manager (Certificate Management)
- External DNS
- MetalLB (Load Balancer)
- CoreDNS (DNS)
- CSI (Container Storage Interface)
- Metrics Server
- Gateway API

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.0.2 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 3.5.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.37.1 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | 5.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.0.2 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.37.1 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_vault"></a> [vault](#provider\_vault) | 5.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_common"></a> [common](#module\_common) | ../modules/common | n/a |
| <a name="module_external_secrets_vault_authentication"></a> [external\_secrets\_vault\_authentication](#module\_external\_secrets\_vault\_authentication) | ../modules/kubernetes-vault-authentication | n/a |
| <a name="module_vault_pki_auth"></a> [vault\_pki\_auth](#module\_vault\_pki\_auth) | ../modules/kubernetes-vault-pki | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.cert_manager](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.cilium](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.cilium_ipam](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.coredns](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.external_dns](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.external_secrets](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.local_path_provisioner](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.secret_store](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.vault_cluster_issuer](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [kubernetes_namespace_v1.argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.cert_manager](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.external_dns](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.external_secrets](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.local_path_provisioner](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/namespace_v1) | resource |
| [kubernetes_secret_v1.external_secrets_token](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/secret_v1) | resource |
| [kubernetes_service_account_v1.external_secrets](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/service_account_v1) | resource |
| [vault_mount.pki](https://registry.terraform.io/providers/hashicorp/vault/5.1.0/docs/resources/mount) | resource |
| [vault_policy.external_secrets_operator](https://registry.terraform.io/providers/hashicorp/vault/5.1.0/docs/resources/policy) | resource |
| [terraform_remote_state.infra](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [vault_kv_secret_v2.environment](https://registry.terraform.io/providers/hashicorp/vault/5.1.0/docs/data-sources/kv_secret_v2) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project"></a> [project](#input\_project) | Name of the Incus project for resource isolation and management. Projects provide boundaries for containers, VMs, networks, and storage. | `string` | n/a | yes |
| <a name="input_cert_manager_config"></a> [cert\_manager\_config](#input\_cert\_manager\_config) | Configuration for cert-manager, the certificate management system for Kubernetes. | <pre>object({<br>    namespace                   = optional(string, "cert-manager")<br>    version                     = optional(string, "v1.15.3")<br>    dns01_recursive_nameservers = optional(string, "8.8.8.8:53,1.1.1.1:53")<br><br>    controller = optional(object({<br>      replica_count = optional(number, 2)<br>      resources = optional(object({<br>        requests = optional(object({<br>          cpu    = optional(string, "20m")<br>          memory = optional(string, "128Mi")<br>        }), {})<br>        limits = optional(object({<br>          cpu    = optional(string, "100m")<br>          memory = optional(string, "256Mi")<br>        }), {})<br>      }), {})<br>    }), {})<br><br>    webhook = optional(object({<br>      replica_count = optional(number, 2)<br>      resources = optional(object({<br>        requests = optional(object({<br>          cpu    = optional(string, "10m")<br>          memory = optional(string, "64Mi")<br>        }), {})<br>        limits = optional(object({<br>          cpu    = optional(string, "100m")<br>          memory = optional(string, "128Mi")<br>        }), {})<br>      }), {})<br>    }), {})<br><br>    cainjector = optional(object({<br>      replica_count = optional(number, 2)<br>      resources = optional(object({<br>        requests = optional(object({<br>          cpu    = optional(string, "20m")<br>          memory = optional(string, "320Mi")<br>        }), {})<br>        limits = optional(object({<br>          cpu    = optional(string, "100m")<br>          memory = optional(string, "512Mi")<br>        }), {})<br>      }), {})<br>    }), {})<br>  })</pre> | `{}` | no |
| <a name="input_cilium_config"></a> [cilium\_config](#input\_cilium\_config) | Configuration for Cilium, an eBPF-based networking platform. | <pre>object({<br>    namespace = optional(string, "kube-system")<br>    version   = optional(string, "1.18.0")<br>    mtu       = optional(number, 1430)<br>    log_level = optional(string, "info")<br>    ipam = optional(object({<br>      advertised_ranges = optional(list(object({<br>        start = string<br>        stop  = string<br>      })))<br>    }), {})<br>  })</pre> | <pre>{<br>  "ipam": {<br>    "advertised_ranges": [<br>      {<br>        "start": "10.191.0.100",<br>        "stop": "10.191.0.120"<br>      }<br>    ]<br>  }<br>}</pre> | no |
| <a name="input_coredns_config"></a> [coredns\_config](#input\_coredns\_config) | Configuration for CoreDNS. | <pre>object({<br>    namespace = optional(string, "kube-system")<br>    version   = optional(string, "1.39.2")<br><br>    autoscaler = optional(object({<br>      enabled           = optional(bool, true)<br>      cores_per_replica = optional(number, 32)<br>      nodes_per_replica = optional(number, 2)<br>      min               = optional(number, 5)<br>      max               = optional(number, 0)<br>    }), {})<br><br>    cache_duration     = optional(number, 30)<br>    additional_plugins = optional(list(map(any)), [])<br>  })</pre> | <pre>{<br>  "autoscaler": {<br>    "enabled": false<br>  }<br>}</pre> | no |
| <a name="input_external_dns_config"></a> [external\_dns\_config](#input\_external\_dns\_config) | Configuration for ExternalDNS, which automatically manages DNS records for Kubernetes services. | <pre>object({<br>    namespace       = optional(string, "external-dns")<br>    version         = optional(string, "9.0.0")<br>    log_level       = optional(string, "info")<br>    log_format      = optional(string, "json")<br>    nameserver_host = optional(string)<br><br>    resources = optional(object({<br>      requests = optional(object({<br>        cpu    = optional(string, "30m")<br>        memory = optional(string, "128Mi")<br>      }), {})<br>      limits = optional(object({<br>        cpu    = optional(string, "300m")<br>        memory = optional(string, "512Mi")<br>      }), {})<br>    }), {})<br>  })</pre> | `{}` | no |
| <a name="input_external_secrets_config"></a> [external\_secrets\_config](#input\_external\_secrets\_config) | n/a | <pre>object({<br>    namespace = optional(string, "external-secrets")<br>    version   = optional(string, "0.18.2")<br>    vault_config = optional(object({<br>      mount = optional(string, "kubernetes-secrets")<br>      auth = optional(object({<br>        mount_path = optional(string, "kubernetes")<br>        role_name  = optional(string, "external-secrets")<br>      }), {})<br>    }), {})<br>  })</pre> | `{}` | no |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to the Kubeconfig file. | `string` | `"/tmp/kubeconfig.yml"` | no |
| <a name="input_vault_address"></a> [vault\_address](#input\_vault\_address) | n/a | `string` | `"https://vault.uzbunitim.me:8200"` | no |
| <a name="input_vault_pki_issuer_config"></a> [vault\_pki\_issuer\_config](#input\_vault\_pki\_issuer\_config) | n/a | <pre>object({<br>    mount                = optional(string, "pki-kubernetes")<br>    role_name            = optional(string, "cert-manager")<br>    allowed_domains      = optional(list(string), ["uzbunitim.me", "svc.cluster.local", "cluster.local", "local"])<br>    service_account_name = optional(string, "vault-cluster-issuer")<br>    auth_backend         = optional(string, "kubernetes")<br>  })</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
