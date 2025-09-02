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
| <a name="requirement_tailscale"></a> [tailscale](#requirement\_tailscale) | 0.21.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tailscale"></a> [tailscale](#provider\_tailscale) | 0.21.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_common"></a> [common](#module\_common) | ../modules/common | n/a |

## Resources

| Name | Type |
|------|------|
| [tailscale_device_authorization.this](https://registry.terraform.io/providers/tailscale/tailscale/0.21.1/docs/resources/device_authorization) | resource |
| [tailscale_device_subnet_routes.root](https://registry.terraform.io/providers/tailscale/tailscale/0.21.1/docs/resources/device_subnet_routes) | resource |
| [tailscale_dns_nameservers.this](https://registry.terraform.io/providers/tailscale/tailscale/0.21.1/docs/resources/dns_nameservers) | resource |
| [tailscale_dns_preferences.this](https://registry.terraform.io/providers/tailscale/tailscale/0.21.1/docs/resources/dns_preferences) | resource |
| [tailscale_dns_search_paths.this](https://registry.terraform.io/providers/tailscale/tailscale/0.21.1/docs/resources/dns_search_paths) | resource |
| [tailscale_device.root](https://registry.terraform.io/providers/tailscale/tailscale/0.21.1/docs/data-sources/device) | data source |
| [tailscale_device.this](https://registry.terraform.io/providers/tailscale/tailscale/0.21.1/docs/data-sources/device) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_devices"></a> [devices](#input\_devices) | List of Tailscale devices to configure with routing | <pre>list(object({<br>    name   = string<br>    routes = optional(list(string), ["10.190.0.0/16", "10.191.0.0/16"])<br>  }))</pre> | `[]` | no |
| <a name="input_public_nameservers"></a> [public\_nameservers](#input\_public\_nameservers) | Public nameservers to use alongside internal resolver | `list(string)` | <pre>[<br>  "8.8.8.8",<br>  "8.8.4.4"<br>]</pre> | no |
| <a name="input_root_node_config"></a> [root\_node\_config](#input\_root\_node\_config) | Configuration for the root Tailscale node with exit node routing | <pre>object({<br>    device_name = optional(string, "peter")<br>    routes      = optional(list(string), ["10.190.0.0/16", "10.191.0.0/16", "0.0.0.0/0", "::/0"])<br>  })</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
