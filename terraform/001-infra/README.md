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
| <a name="requirement_incus"></a> [incus](#requirement\_incus) | 0.3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.7.2 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | 2.3.6 |
| <a name="provider_incus"></a> [incus](#provider\_incus) | 0.3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_common"></a> [common](#module\_common) | ../modules/common | n/a |

## Resources

| Name | Type |
|------|------|
| [incus_instance.dns](https://registry.terraform.io/providers/lxc/incus/0.3.0/docs/resources/instance) | resource |
| [random_bytes.tsig](https://registry.terraform.io/providers/hashicorp/random/3.7.2/docs/resources/bytes) | resource |
| [cloudinit_config.dns](https://registry.terraform.io/providers/hashicorp/cloudinit/2.3.6/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dns_config"></a> [dns\_config](#input\_dns\_config) | Configuration for DNS infrastructure using Knot DNS server. Manages DNS zones with TSIG authentication and proper SOA record settings. | <pre>object({<br>    replicas = number<br>    profile  = optional(string, "infra-1-1-20")<br>    zones = list(object({<br>      name = string<br>      config = optional(object({<br>        ttl                = number<br>        refresh            = number<br>        retry              = number<br>        expire             = number<br>        negative_cache_ttl = number<br>        }), {<br>        ttl                = 300    # 5 minutes<br>        refresh            = 3600   # 1 hour<br>        retry              = 900    # 15 minutes<br>        expire             = 604800 # 1 week<br>        negative_cache_ttl = 3600   # 1 hour<br>      })<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Name of the Incus project for resource isolation and management. Projects provide boundaries for containers, VMs, networks, and storage. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tsig_keys"></a> [tsig\_keys](#output\_tsig\_keys) | n/a |
<!-- END_TF_DOCS -->
