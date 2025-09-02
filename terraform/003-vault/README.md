# Vault

This project configures HashiCorp Vault with authentication, authorization, and secret management.

## Stack

- HashiCorp Vault
- LDAP Authentication
- PKI (Public Key Infrastructure)
- RBAC (Role-Based Access Control)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | 5.0.0-me |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_vault"></a> [vault](#provider\_vault) | 5.0.0-me |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_common"></a> [common](#module\_common) | ../modules/common | n/a |

## Resources

| Name | Type |
|------|------|
| vault_audit.this | resource |
| vault_auth_backend.ldap | resource |
| vault_auth_backend.this | resource |
| vault_kv_secret_v2.environment | resource |
| vault_ldap_auth_backend.this | resource |
| vault_ldap_auth_backend_group.admin | resource |
| vault_ldap_auth_backend_group.guest | resource |
| vault_mount.core | resource |
| vault_mount.guest | resource |
| vault_mount.pki | resource |
| vault_mount.pki_intermediate | resource |
| vault_mount.this | resource |
| vault_pki_secret_backend_config_urls.this | resource |
| vault_pki_secret_backend_intermediate_cert_request.intermediate | resource |
| vault_pki_secret_backend_intermediate_set_signed.intermediate | resource |
| vault_pki_secret_backend_issuer.root | resource |
| vault_pki_secret_backend_role.this | resource |
| vault_pki_secret_backend_root_cert.this | resource |
| vault_pki_secret_backend_root_sign_intermediate.intermediate | resource |
| vault_policy.admin | resource |
| vault_policy.guest | resource |
| vault_policy.read_env | resource |
| [terraform_remote_state.infra](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ldap_backend_config"></a> [ldap\_backend\_config](#input\_ldap\_backend\_config) | Configuration for Vault's LDAP authentication backend. Defines how Vault connects to and queries the LDAP server for user authentication and group membership. | <pre>object({<br>    url         = string<br>    userdn      = string<br>    userattr    = optional(string, "cn")<br>    groupdn     = string<br>    groupattr   = optional(string, "cn")<br>    groupfilter = optional(string, "(&(objectClass=posixGroup)(memberUid={{.Username}}))")<br>  })</pre> | n/a | yes |
| <a name="input_ldap_bind_dn"></a> [ldap\_bind\_dn](#input\_ldap\_bind\_dn) | Distinguished Name (DN) of the LDAP user account that Vault will use to bind to the LDAP server for authentication queries. | `string` | n/a | yes |
| <a name="input_ldap_bind_password"></a> [ldap\_bind\_password](#input\_ldap\_bind\_password) | Password for the LDAP bind user. This credential is used by Vault to authenticate with the LDAP server for user lookups and group membership queries. | `string` | n/a | yes |
| <a name="input_auth_backends"></a> [auth\_backends](#input\_auth\_backends) | n/a | <pre>list(object({<br>    type = string<br>    path = string<br>  }))</pre> | `[]` | no |
| <a name="input_mounts"></a> [mounts](#input\_mounts) | n/a | <pre>list(object({<br>    path    = string<br>    type    = string<br>    options = optional(map(string), {})<br>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
