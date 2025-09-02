# Kubernetes Vault PKI

Sets up Vault PKI intermediate CA for Kubernetes certificate management with cert-manager integration.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0.2 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.4.5 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.37.1 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | ~> 5.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_http"></a> [http](#provider\_http) | ~> 3.4.5 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.37.1 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | ~> 5.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [vault_pki_secret_backend_config_urls.this](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_config_urls) | resource |
| [vault_pki_secret_backend_intermediate_cert_request.this](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_intermediate_cert_request) | resource |
| [vault_pki_secret_backend_root_sign_intermediate.this](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_root_sign_intermediate) | resource |
| [vault_pki_secret_backend_intermediate_set_signed.this](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_intermediate_set_signed) | resource |
| [vault_pki_secret_backend_config_issuers.this](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_config_issuers) | resource |
| [vault_pki_secret_backend_role.cert_manager](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_role) | resource |
| [vault_policy.vault_cluster_issuer](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [vault_kubernetes_auth_backend_config.cert_manager](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kubernetes_auth_backend_config) | resource |
| [vault_kubernetes_auth_backend_role.cert_manager](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kubernetes_auth_backend_role) | resource |
| [http_http.pki_intermediate_ca](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_domains"></a> [allowed\_domains](#input\_allowed\_domains) | List of domains allowed for certificate issuance | `list(string)` | n/a | yes |
| <a name="input_kubernetes_config"></a> [kubernetes\_config](#input\_kubernetes\_config) | Kubernetes cluster connection configuration | <pre>object({<br>    ca_cert = string<br>    host    = string<br>  })</pre> | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace for cert-manager service account | `string` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of the Vault PKI role | `string` | n/a | yes |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | Name of the cert-manager service account | `string` | n/a | yes |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | Certificate TTL in seconds | `number` | n/a | yes |
| <a name="input_vault_address"></a> [vault\_address](#input\_vault\_address) | Vault server address for API calls | `string` | n/a | yes |
| <a name="input_vault_mount"></a> [vault\_mount](#input\_vault\_mount) | Vault PKI mount path for certificates | `string` | n/a | yes |
| <a name="input_issuer_name"></a> [issuer\_name](#input\_issuer\_name) | Name for the PKI issuer policy | `string` | `"pki-kubernetes-intermediate"` | no |
| <a name="input_key_bits"></a> [key\_bits](#input\_key\_bits) | RSA key size in bits | `number` | `2048` | no |
| <a name="input_signer_name"></a> [signer\_name](#input\_signer\_name) | Vault PKI mount name for signing intermediate CA | `string` | `"pki-intermediate"` | no |
| <a name="input_vault_auth_backend"></a> [vault\_auth\_backend](#input\_vault\_auth\_backend) | Vault Kubernetes auth backend name | `string` | `"kubernetes"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
