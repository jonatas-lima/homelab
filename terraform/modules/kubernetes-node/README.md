# RKE2 Kubernetes Node - Incus

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | 2.3.6 |
| <a name="requirement_incus"></a> [incus](#requirement\_incus) | 0.3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.7.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | 2.3.6 |
| <a name="provider_incus"></a> [incus](#provider\_incus) | 0.3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [incus_instance.this](https://registry.terraform.io/providers/lxc/incus/0.3.0/docs/resources/instance) | resource |
| [random_id.this](https://registry.terraform.io/providers/hashicorp/random/3.7.2/docs/resources/id) | resource |
| [cloudinit_config.this](https://registry.terraform.io/providers/hashicorp/cloudinit/2.3.6/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_config"></a> [common\_config](#input\_common\_config) | n/a | <pre>object({<br>    advertise_address = string<br>    apiserver_dns     = optional(string)<br>    tls_san           = optional(list(string), [])<br>    bootstrap_server  = string<br>  })</pre> | n/a | yes |
| <a name="input_node_config"></a> [node\_config](#input\_node\_config) | n/a | <pre>object({<br>    role                  = string<br>    bootstrap             = optional(bool, false)<br>    kube_apiserver_args   = optional(map(string), {})<br>    kubelet_args          = optional(list(string), [])<br>    etcd_args             = optional(map(string), {})<br>    components_to_disable = optional(list(string), [])<br>    node_labels           = optional(map(string), {})<br>  })</pre> | n/a | yes |
| <a name="input_profile"></a> [profile](#input\_profile) | Incus profile | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Incus project. | `string` | n/a | yes |
| <a name="input_token"></a> [token](#input\_token) | RKE2 token. | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | n/a | `string` | `"images:ubuntu/24.04/cloud"` | no |
| <a name="input_rke2_version"></a> [rke2\_version](#input\_rke2\_version) | RKE2 version to install. | `string` | `"1.33.1+rke2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudinit"></a> [cloudinit](#output\_cloudinit) | n/a |
| <a name="output_instance"></a> [instance](#output\_instance) | n/a |
<!-- END_TF_DOCS -->
