# Infra

## DNS

- Stack: bind9
- Number of nodes: 1
- Type: VM
- Flavor: 1vCPU, 1GB RAM
- Image: Ubuntu 24.04

**IMPORTANT ADR**: One TSIG key for all zones.

### How to

#### Add a new zone

1. Add your new zone in `/etc/bind/named.conf.local`:

    ```text
    zone "newzone.uzbunitim.com" {
      type master;
      file "/etc/bind/zones/db.newzone.uzbunitim.com";
      allow-transfer {
        key "uzbunitim.com.";
      };
      update-policy {
        grant uzbunitim.com. zonesub ANY;
      };
    };
    ```

1. Add your zone conf in `/etc/bind/zones/db.newzone.uzbunitin.com`:

    ```text
    $ORIGIN .

    $TTL 604800 ; 1 week
    newzone.uzbunitim.com  IN SOA ns1.newzone.uzbunitim.com. root.newzone.uzbunitim.com. (
        7          ; serial
        604800     ; refresh (1 week)
        86400      ; retry (1 day)
        2419200    ; expire (4 weeks)
        604800     ; minimum (1 week)
        )

      NS ns1.uzbunitim.com.
    ```

1. Restart `named`:

    ```bash
    systemctl restart named
    ```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | 2.3.6 |
| <a name="requirement_dns"></a> [dns](#requirement\_dns) | 3.4.2 |
| <a name="requirement_incus"></a> [incus](#requirement\_incus) | 0.3.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | 2.3.6 |
| <a name="provider_dns"></a> [dns](#provider\_dns) | 3.4.2 |
| <a name="provider_incus"></a> [incus](#provider\_incus) | 0.3.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_common"></a> [common](#module\_common) | ../modules/common | n/a |

## Resources

| Name | Type |
|------|------|
| [dns_a_record_set.glauth](https://registry.terraform.io/providers/hashicorp/dns/3.4.2/docs/resources/a_record_set) | resource |
| [dns_a_record_set.glauth_lb](https://registry.terraform.io/providers/hashicorp/dns/3.4.2/docs/resources/a_record_set) | resource |
| [dns_a_record_set.vault](https://registry.terraform.io/providers/hashicorp/dns/3.4.2/docs/resources/a_record_set) | resource |
| [dns_a_record_set.vault_lb](https://registry.terraform.io/providers/hashicorp/dns/3.4.2/docs/resources/a_record_set) | resource |
| [incus_instance.glauth](https://registry.terraform.io/providers/lxc/incus/0.3.0/docs/resources/instance) | resource |
| [incus_instance.vault](https://registry.terraform.io/providers/lxc/incus/0.3.0/docs/resources/instance) | resource |
| [incus_network_lb.glauth](https://registry.terraform.io/providers/lxc/incus/0.3.0/docs/resources/network_lb) | resource |
| [incus_network_lb.vault](https://registry.terraform.io/providers/lxc/incus/0.3.0/docs/resources/network_lb) | resource |
| [tls_cert_request.vault](https://registry.terraform.io/providers/hashicorp/tls/4.1.0/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.vault](https://registry.terraform.io/providers/hashicorp/tls/4.1.0/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.glauth](https://registry.terraform.io/providers/hashicorp/tls/4.1.0/docs/resources/private_key) | resource |
| [tls_private_key.vault](https://registry.terraform.io/providers/hashicorp/tls/4.1.0/docs/resources/private_key) | resource |
| [tls_private_key.vault_ca](https://registry.terraform.io/providers/hashicorp/tls/4.1.0/docs/resources/private_key) | resource |
| [tls_self_signed_cert.glauth](https://registry.terraform.io/providers/hashicorp/tls/4.1.0/docs/resources/self_signed_cert) | resource |
| [tls_self_signed_cert.vault_ca](https://registry.terraform.io/providers/hashicorp/tls/4.1.0/docs/resources/self_signed_cert) | resource |
| [cloudinit_config.glauth](https://registry.terraform.io/providers/hashicorp/cloudinit/2.3.6/docs/data-sources/config) | data source |
| [cloudinit_config.vault](https://registry.terraform.io/providers/hashicorp/cloudinit/2.3.6/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_glauth_config"></a> [glauth\_config](#input\_glauth\_config) | Configuration for GLAuth LDAP server. GLAuth provides lightweight LDAP authentication and authorization for homelab services. | <pre>object({<br>    replicas         = optional(number, 1)<br>    version          = optional(string, "v2.4.0")<br>    profile          = optional(string, "infra-1-2-20")<br>    load_balancer_ip = optional(string, "10.190.11.11")<br>    common_name      = optional(string, "ldap.uzbunitim.me")<br>    server = object({<br>      ldap_port  = optional(number, 3893)<br>      ldaps_port = optional(number, 3894)<br>      tracing_config = optional(object({<br>        enabled = optional(bool, false)<br>      }), {})<br>      backend_config = optional(object({<br>        base_dn = string<br>        legacy  = optional(bool, false)<br>      }))<br>      users = optional(list(object({<br>        name         = string<br>        uid          = number<br>        primary_gid  = number<br>        login_shell  = optional(string, "/bin/bash")<br>        pass_sha_256 = string<br>        capabilities = optional(list(object({<br>          action = string<br>          object = string<br>        })), [])<br>      })), [])<br>      groups = optional(list(object({<br>        name = string<br>        gid  = string<br>        capabilities = optional(list(object({<br>          action = string<br>          object = string<br>        })), [])<br>      })), [])<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Name of the Incus project for resource isolation and management. Projects provide boundaries for containers, VMs, networks, and storage. | `string` | n/a | yes |
| <a name="input_vault_config"></a> [vault\_config](#input\_vault\_config) | Configuration for HashiCorp Vault secret management server. Vault provides secure storage and access to secrets, certificates, and sensitive data. | <pre>object({<br>    replicas         = optional(number, 1)<br>    profile          = optional(string, "infra-apps-2-4-20")<br>    common_name      = optional(string, "vault.uzbunitim.me")<br>    load_balancer_ip = optional(string, "10.190.11.10")<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vault_certs"></a> [vault\_certs](#output\_vault\_certs) | n/a |
<!-- END_TF_DOCS -->
