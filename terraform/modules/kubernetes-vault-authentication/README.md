# Kubernetes Vault Authentication

Sets up Vault Kubernetes authentication backend for service account based authentication.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.37.1 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | ~> 5.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.37.1 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | ~> 5.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [vault_kubernetes_auth_backend_config.this](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kubernetes_auth_backend_config) | resource |
| [vault_kubernetes_auth_backend_role.this](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kubernetes_auth_backend_role) | resource |
| [kubernetes_cluster_role_binding_v1.token_reviewer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding_v1) | resource |
| [kubernetes_secret_v1.service_account_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/secret_v1) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kubernetes_config"></a> [kubernetes\_config](#input\_kubernetes\_config) | Kubernetes cluster connection configuration | <pre>object({<br>    ca_cert = string<br>    host    = string<br>  })</pre> | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace for the service account | `string` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of the Vault Kubernetes auth role | `string` | n/a | yes |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | Name of the Kubernetes service account | `string` | n/a | yes |
| <a name="input_policies"></a> [policies](#input\_policies) | List of Vault policies to attach to the role | `list(string)` | `[]` | no |
| <a name="input_vault_auth_backend"></a> [vault\_auth\_backend](#input\_vault\_auth\_backend) | Vault Kubernetes auth backend name | `string` | `"kubernetes"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
