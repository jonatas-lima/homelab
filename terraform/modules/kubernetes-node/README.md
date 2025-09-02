# RKE2 Kubernetes Node - Incus

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.3.6 |
| <a name="requirement_incus"></a> [incus](#requirement\_incus) | >= 0.3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.7.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | >= 2.3.6 |
| <a name="provider_incus"></a> [incus](#provider\_incus) | >= 0.3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.7.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [incus_instance.this](https://registry.terraform.io/providers/lxc/incus/latest/docs/resources/instance) | resource |
| [random_id.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [cloudinit_config.this](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_config"></a> [common\_config](#input\_common\_config) | Common configuration shared across all nodes in the Kubernetes cluster for networking and security. | <pre>object({<br>    advertise_address = string<br>    apiserver_dns     = optional(string)<br>    tls_san           = optional(list(string), [])<br>    bootstrap_server  = string<br>  })</pre> | n/a | yes |
| <a name="input_node_config"></a> [node\_config](#input\_node\_config) | RKE2-specific configuration for the Kubernetes node. Defines the node role, component settings, and customizations. | <pre>object({<br>    role                  = string<br>    bootstrap             = optional(bool, false)<br>    kube_apiserver_args   = optional(map(string), {})<br>    kubelet_args          = optional(list(string), [])<br>    etcd_args             = optional(map(string), {})<br>    components_to_disable = optional(list(string), [])<br>    node_labels           = optional(map(string), {})<br>  })</pre> | n/a | yes |
| <a name="input_profile"></a> [profile](#input\_profile) | Incus profile defining the hardware configuration (CPU, memory, storage) for the Kubernetes node instance. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Incus project where the Kubernetes node instance will be created. Projects provide isolation and resource management. | `string` | n/a | yes |
| <a name="input_token"></a> [token](#input\_token) | Shared secret token for node authentication and cluster joining. | `string` | n/a | yes |
| <a name="input_additional_devices"></a> [additional\_devices](#input\_additional\_devices) | n/a | <pre>list(object({<br>    name       = string<br>    type       = string<br>    properties = map(string)<br>  }))</pre> | `[]` | no |
| <a name="input_image"></a> [image](#input\_image) | Container image to use for the Kubernetes node. Uses Ubuntu 24.04 cloud image by default for compatibility with RKE2. | `string` | `"images:ubuntu/24.04/cloud"` | no |
| <a name="input_rke2_version"></a> [rke2\_version](#input\_rke2\_version) | RKE2 (Rancher Kubernetes Engine 2) version to install on the node. Should match across all cluster nodes for compatibility. | `string` | `"1.33.1+rke2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudinit"></a> [cloudinit](#output\_cloudinit) | n/a |
| <a name="output_instance"></a> [instance](#output\_instance) | n/a |
<!-- END_TF_DOCS -->
