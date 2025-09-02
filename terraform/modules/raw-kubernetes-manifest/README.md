# Raw Kubernetes Manifest

Download and install a raw Kubernetes manifest from a URL.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0.2 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.5.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.37.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 3.0.2 |
| <a name="provider_http"></a> [http](#provider\_http) | ~> 3.5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [http_http.this](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name for the Helm release | `string` | n/a | yes |
| <a name="input_url"></a> [url](#input\_url) | URL to download raw Kubernetes manifest file. The manifest should contain YAML resources that will be applied to the cluster. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace to deploy resources | `string` | `"default"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
