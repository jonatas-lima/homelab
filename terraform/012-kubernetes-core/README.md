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
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.17.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.37.1 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.17.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.37.1 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_common"></a> [common](#module\_common) | ../modules/common | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.cert_manager](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [helm_release.cilium](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [helm_release.coredns](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [helm_release.external_dns](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [helm_release.internal_gateway](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [helm_release.local_path_provisioner](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [helm_release.metallb](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [helm_release.metallb_ipam](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [helm_release.traefik](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [kubernetes_namespace_v1.cert_manager](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.external_dns](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.internal_gateway](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.local_path_provisioner](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.metallb](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.traefik](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/namespace_v1) | resource |
| [vault_kv_secret_v2.environment](https://registry.terraform.io/providers/hashicorp/vault/5.0.0/docs/data-sources/kv_secret_v2) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project"></a> [project](#input\_project) | Name of the Incus project for resource isolation and management. Projects provide boundaries for containers, VMs, networks, and storage. | `string` | n/a | yes |
| <a name="input_cert_manager_config"></a> [cert\_manager\_config](#input\_cert\_manager\_config) | Configuration for cert-manager, the certificate management system for Kubernetes. | <pre>object({<br>    namespace                   = optional(string, "cert-manager")<br>    version                     = optional(string, "v1.15.3")<br>    dns01_recursive_nameservers = optional(string, "8.8.8.8:53,1.1.1.1:53")<br><br>    controller = optional(object({<br>      replica_count = optional(number, 3)<br>      resources = optional(object({<br>        requests = optional(object({<br>          cpu    = optional(string, "20m")<br>          memory = optional(string, "128Mi")<br>        }), {})<br>        limits = optional(object({<br>          cpu    = optional(string, "100m")<br>          memory = optional(string, "256Mi")<br>        }), {})<br>      }), {})<br>    }), {})<br><br>    webhook = optional(object({<br>      replica_count = optional(number, 3)<br>      resources = optional(object({<br>        requests = optional(object({<br>          cpu    = optional(string, "10m")<br>          memory = optional(string, "64Mi")<br>        }), {})<br>        limits = optional(object({<br>          cpu    = optional(string, "100m")<br>          memory = optional(string, "128Mi")<br>        }), {})<br>      }), {})<br>    }), {})<br><br>    cainjector = optional(object({<br>      replica_count = optional(number, 3)<br>      resources = optional(object({<br>        requests = optional(object({<br>          cpu    = optional(string, "20m")<br>          memory = optional(string, "320Mi")<br>        }), {})<br>        limits = optional(object({<br>          cpu    = optional(string, "100m")<br>          memory = optional(string, "512Mi")<br>        }), {})<br>      }), {})<br>    }), {})<br>  })</pre> | `{}` | no |
| <a name="input_cilium_config"></a> [cilium\_config](#input\_cilium\_config) | Configuration for Cilium, a eBPF-based networking platform. | <pre>object({<br>    namespace = optional(string, "kube-system")<br>    version   = optional(string, "1.17.2")<br>    mtu       = optional(number, 1430)<br>    log_level = optional(string, "info")<br>  })</pre> | `{}` | no |
| <a name="input_coredns_config"></a> [coredns\_config](#input\_coredns\_config) | Configuration for CoreDNS. | <pre>object({<br>    namespace = optional(string, "kube-system")<br>    version   = optional(string, "1.39.2")<br><br>    autoscaler = optional(object({<br>      enabled           = optional(bool, true)<br>      cores_per_replica = optional(number, 32)<br>      nodes_per_replica = optional(number, 2)<br>      min               = optional(number, 5)<br>      max               = optional(number, 0)<br>    }), {})<br><br>    cache_duration     = optional(number, 30)<br>    additional_plugins = optional(list(map(any)), [])<br>  })</pre> | <pre>{<br>  "autoscaler": {<br>    "enabled": false<br>  }<br>}</pre> | no |
| <a name="input_external_dns_config"></a> [external\_dns\_config](#input\_external\_dns\_config) | Configuration for ExternalDNS, which automatically manages DNS records for Kubernetes services. | <pre>object({<br>    namespace       = optional(string, "external-dns")<br>    version         = optional(string, "1.16.0")<br>    log_level       = optional(string, "info")<br>    log_format      = optional(string, "json")<br>    nameserver_host = optional(string)<br><br>    resources = optional(object({<br>      requests = optional(object({<br>        cpu    = optional(string, "30m")<br>        memory = optional(string, "128Mi")<br>      }), {})<br>      limits = optional(object({<br>        cpu    = optional(string, "300m")<br>        memory = optional(string, "512Mi")<br>      }), {})<br>    }), {})<br>  })</pre> | `{}` | no |
| <a name="input_gateway_api_config"></a> [gateway\_api\_config](#input\_gateway\_api\_config) | Configuration for Gateway API internal gateway setup. | <pre>object({<br>    version = optional(string, "0.3.2")<br>  })</pre> | `{}` | no |
| <a name="input_metallb_config"></a> [metallb\_config](#input\_metallb\_config) | Configuration for MetalLB, a load balancer implementation for bare-metal Kubernetes clusters. | <pre>object({<br>    namespace       = optional(string, "metallb-system")<br>    log_level       = optional(string, "info")<br>    version         = optional(string, "0.14.8")<br>    ip_address_pool = optional(list(string), [])<br><br>    controller = optional(object({<br>      resources = optional(object({<br>        requests = optional(object({<br>          cpu    = optional(string, "30m")<br>          memory = optional(string, "256Mi")<br>        }), {})<br>        limits = optional(object({<br>          cpu    = optional(string, "300m")<br>          memory = optional(string, "1Gi")<br>        }), {})<br>      }), {})<br>    }), {})<br><br>    speaker = optional(object({<br>      resources = optional(object({<br>        requests = optional(object({<br>          cpu    = optional(string, "50m")<br>          memory = optional(string, "128Mi")<br>        }), {})<br>        limits = optional(object({<br>          cpu    = optional(string, "200m")<br>          memory = optional(string, "512Mi")<br>        }), {})<br>      }), {})<br><br>      frr = optional(object({<br>        resources = optional(object({<br>          requests = optional(object({<br>            cpu    = optional(string, "20m")<br>            memory = optional(string, "128Mi")<br>          }), {})<br>          limits = optional(object({<br>            cpu    = optional(string, "300m")<br>            memory = optional(string, "512Mi")<br>          }), {})<br>        }), {})<br>      }), {})<br><br>      frr_metrics = optional(object({<br>        resources = optional(object({<br>          requests = optional(object({<br>            cpu    = optional(string, "40m")<br>            memory = optional(string, "96Mi")<br>          }), {})<br>          limits = optional(object({<br>            cpu    = optional(string, "200m")<br>            memory = optional(string, "512Mi")<br>          }), {})<br>        }), {})<br>      }), {})<br><br>      reloader = optional(object({<br>        resources = optional(object({<br>          requests = optional(object({<br>            cpu    = optional(string, "10m")<br>            memory = optional(string, "32Mi")<br>          }), {})<br>          limits = optional(object({<br>            cpu    = optional(string, "200m")<br>            memory = optional(string, "128Mi")<br>          }), {})<br>        }), {})<br>      }), {})<br>    }), {})<br>  })</pre> | <pre>{<br>  "ip_address_pool": [<br>    "10.191.0.100-10.191.0.120"<br>  ]<br>}</pre> | no |
| <a name="input_traefik_config"></a> [traefik\_config](#input\_traefik\_config) | Configuration for Traefik, a HTTP reverse proxy and load balancer. | <pre>object({<br>    version = optional(string, "v35.4.0")<br>  })</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
