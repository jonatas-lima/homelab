variable "records" {
  description = "Records to add to NS."
  type = list(object({
    name      = string
    zone      = string
    type      = string
    addresses = optional(list(string), [])
    cname     = optional(string)
    ttl       = optional(number, 3600)
  }))
  default = []
}

locals {
  a_records     = { for record in var.records : record.name => record if record.type == "A" }
  cname_records = { for record in var.records : record.name => record if record.type == "CNAME" }
}

resource "dns_a_record_set" "this" {
  for_each = local.a_records

  name      = each.key
  addresses = each.value.addresses
  zone      = each.value.zone
  ttl       = each.value.ttl
}

resource "dns_cname_record" "this" {
  for_each = local.cname_records

  name  = each.key
  cname = each.value.cname
  zone  = each.value.zone
  ttl   = each.value.ttl
}
