# Kubernetes Cluster

This project is responsible for provision and install/configure a Kubernetes cluster in Incus.

## Stack

- RKE2
- Incus

---

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12.0 |
| <a name="requirement_dns"></a> [dns](#requirement\_dns) | 3.4.2 |
| <a name="requirement_incus"></a> [incus](#requirement\_incus) | 0.3.1 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.2.4 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.7.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_dns"></a> [dns](#provider\_dns) | 3.4.2 |
| <a name="provider_incus"></a> [incus](#provider\_incus) | 0.3.1 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_common"></a> [common](#module\_common) | ../modules/common | n/a |
| <a name="module_control_plane"></a> [control\_plane](#module\_control\_plane) | ../modules/kubernetes-node | n/a |
| <a name="module_worker"></a> [worker](#module\_worker) | ../modules/kubernetes-node | n/a |

## Resources

| Name | Type |
|------|------|
| [dns_a_record_set.apiserver](https://registry.terraform.io/providers/hashicorp/dns/3.4.2/docs/resources/a_record_set) | resource |
| [incus_network_lb.control_plane](https://registry.terraform.io/providers/lxc/incus/0.3.1/docs/resources/network_lb) | resource |
| [incus_storage_volume.data](https://registry.terraform.io/providers/lxc/incus/0.3.1/docs/resources/storage_volume) | resource |
| [null_resource.kubeconfig](https://registry.terraform.io/providers/hashicorp/null/3.2.4/docs/resources/resource) | resource |
| [null_resource.wait](https://registry.terraform.io/providers/hashicorp/null/3.2.4/docs/resources/resource) | resource |
| [random_bytes.token](https://registry.terraform.io/providers/hashicorp/random/3.7.2/docs/resources/bytes) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project"></a> [project](#input\_project) | Name of the Incus project for resource isolation and management. Projects provide boundaries for containers, VMs, networks, and storage. | `string` | n/a | yes |
| <a name="input_control_plane"></a> [control\_plane](#input\_control\_plane) | Configuration for Kubernetes control plane nodes. | <pre>object({<br>    replicas = optional(number, 1)<br>    profile  = optional(string, "kubernetes-2-4-50")<br>  })</pre> | `{}` | no |
| <a name="input_rke2_version"></a> [rke2\_version](#input\_rke2\_version) | RKE2 (Rancher Kubernetes Engine 2) version to install. | `string` | `"v1.33.1+rke2r1"` | no |
| <a name="input_workers"></a> [workers](#input\_workers) | Configuration for Kubernetes worker nodes. | <pre>object({<br>    replicas = optional(number, 2)<br>    profile  = optional(string, "kubernetes-2-4-50")<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_control_plane"></a> [control\_plane](#output\_control\_plane) | n/a |
| <a name="output_dns"></a> [dns](#output\_dns) | n/a |
| <a name="output_worker"></a> [worker](#output\_worker) | n/a |
<!-- END_TF_DOCS -->
