# Kubernetes CRDs

This project installs and manages Kubernetes Custom Resource Definitions (CRDs) for various operators and controllers.

## Stack

- Gateway API CRDs
- Traefik CRDs
- Kube-Prometheus CRDs

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

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_common"></a> [common](#module\_common) | ../modules/common | n/a |
| <a name="module_gateway_api"></a> [gateway\_api](#module\_gateway\_api) | ../modules/raw-kubernetes-manifest | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.kube_prometheus_crds](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [kubernetes_namespace_v1.kube_prometheus](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/namespace_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project"></a> [project](#input\_project) | Name of the Incus project for resource isolation and management. Projects provide boundaries for containers, VMs, networks, and storage. | `string` | n/a | yes |
| <a name="input_gateway_api_config"></a> [gateway\_api\_config](#input\_gateway\_api\_config) | Configuration for the Kubernetes Gateway API CRDs installation. | <pre>object({<br>    version = optional(string, "v1.2.0")<br>  })</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
