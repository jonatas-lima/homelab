# DNS

This project manages DNS records and external DNS configuration.

## Stack

- DNS records management
- External DNS integration

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12.0 |
| <a name="requirement_dns"></a> [dns](#requirement\_dns) | 3.4.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_dns"></a> [dns](#provider\_dns) | 3.4.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [dns_a_record_set.this](https://registry.terraform.io/providers/hashicorp/dns/3.4.2/docs/resources/a_record_set) | resource |
| [dns_cname_record.this](https://registry.terraform.io/providers/hashicorp/dns/3.4.2/docs/resources/cname_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_records"></a> [records](#input\_records) | DNS records to create in the managed zones. Supports A records (with IP addresses) and CNAME records (with canonical names). Each record specifies the zone, type, and relevant data. | <pre>list(object({<br>    name      = string<br>    zone      = string<br>    type      = string<br>    addresses = optional(list(string), [])<br>    cname     = optional(string)<br>    ttl       = optional(number, 3600)<br>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
