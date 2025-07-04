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
| <a name="requirement_incus"></a> [incus](#requirement\_incus) | 0.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_incus"></a> [incus](#provider\_incus) | 0.3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_common"></a> [common](#module\_common) | ../modules/common | n/a |

## Resources

| Name | Type |
|------|------|
| [incus_network.this](https://registry.terraform.io/providers/lxc/incus/0.3.0/docs/resources/network) | resource |
| [incus_profile.this](https://registry.terraform.io/providers/lxc/incus/0.3.0/docs/resources/profile) | resource |
| [incus_project.this](https://registry.terraform.io/providers/lxc/incus/0.3.0/docs/resources/project) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_networks"></a> [networks](#input\_networks) | Configuration for Incus networks. Each network defines networking infrastructure including OVN or bridge networks with custom configurations. | <pre>list(object({<br>    name    = string<br>    project = string<br>    type    = string<br>    config  = map(string)<br>  }))</pre> | n/a | yes |
| <a name="input_profiles"></a> [profiles](#input\_profiles) | Incus profiles define hardware configurations (flavors) for instances. Each profile can have multiple flavors with different CPU, memory, and storage configurations. | <pre>list(object({<br>    name    = string<br>    network = string<br>    project = optional(string, "default")<br>    flavors = list(object({<br>      vcpus  = number<br>      memory = number<br>      storage = object({<br>        pool = optional(string, "default")<br>        size = number<br>      })<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_projects"></a> [projects](#input\_projects) | List of Incus project names to create. Projects provide isolation and resource management for containers and VMs. | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
