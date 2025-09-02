# Incus

This project sets up the basic Incus infrastructure including networks, profiles, and projects.

## Stack

- Incus
- OVN Network

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12.0 |
| <a name="requirement_incus"></a> [incus](#requirement\_incus) | 0.3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_incus"></a> [incus](#provider\_incus) | 0.3.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_common"></a> [common](#module\_common) | ../modules/common | n/a |

## Resources

| Name | Type |
|------|------|
| [incus_network.this](https://registry.terraform.io/providers/lxc/incus/0.3.1/docs/resources/network) | resource |
| [incus_profile.this](https://registry.terraform.io/providers/lxc/incus/0.3.1/docs/resources/profile) | resource |
| [incus_project.this](https://registry.terraform.io/providers/lxc/incus/0.3.1/docs/resources/project) | resource |
| [incus_storage_pool.this](https://registry.terraform.io/providers/lxc/incus/0.3.1/docs/resources/storage_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_networks"></a> [networks](#input\_networks) | Configuration for Incus networks. Each network defines networking infrastructure including OVN or bridge networks with custom configurations. | <pre>list(object({<br>    name    = string<br>    project = string<br>    type    = string<br>    config  = map(string)<br>  }))</pre> | n/a | yes |
| <a name="input_nameservers"></a> [nameservers](#input\_nameservers) | DNS nameservers para os profiles | `map(list(string))` | <pre>{<br>  "apps": [<br>    "10.191.1.3"<br>  ]<br>}</pre> | no |
| <a name="input_profiles"></a> [profiles](#input\_profiles) | Incus profiles define hardware configurations (flavors) for instances. Each profile can have multiple flavors with different CPU, memory, and storage configurations. | <pre>list(object({<br>    name    = string<br>    network = string<br>    project = optional(string, "default")<br>    flavors = list(object({<br>      vcpus  = number<br>      memory = number<br>      storage = object({<br>        pool = optional(string, "default")<br>        size = number<br>      })<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_projects"></a> [projects](#input\_projects) | List of Incus project names to create. Projects provide isolation and resource management for containers and VMs. | `list(string)` | `[]` | no |
| <a name="input_storage_pools"></a> [storage\_pools](#input\_storage\_pools) | n/a | <pre>list(object({<br>    name   = string<br>    driver = optional(string, "btrfs")<br>    config = optional(map(string), {})<br>  }))</pre> | <pre>[<br>  {<br>    "config": {<br>      "source": "/data"<br>    },<br>    "name": "kubernetes"<br>  }<br>]</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
