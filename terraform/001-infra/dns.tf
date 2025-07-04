variable "dns_config" {
  description = "Configuration for DNS infrastructure using Knot DNS server. Manages DNS zones with TSIG authentication and proper SOA record settings."
  type = object({
    replicas = number
    profile  = optional(string, "infra-1-1-20")
    zones = list(object({
      name = string
      config = optional(object({
        ttl                = number
        refresh            = number
        retry              = number
        expire             = number
        negative_cache_ttl = number
        }), {
        ttl                = 300    # 5 minutes
        refresh            = 3600   # 1 hour
        retry              = 900    # 15 minutes
        expire             = 604800 # 1 week
        negative_cache_ttl = 3600   # 1 hour
      })
    }))
  })
}

locals {
  ubuntu_24_04_cloud = "images:ubuntu/noble/cloud"
  dns_zones          = [for zone in var.dns_config.zones : merge(zone, { key = random_bytes.tsig[zone.name].base64 })]
}

locals {
  knot_conf = templatefile("./templates/dns/knot.conf.tpl", {
    zones = local.dns_zones
  })
  dns_cloudinit = templatefile("./templates/dns/knot-cloud-init.yaml.tpl", {
    knot_conf = base64encode(local.knot_conf)
    zones     = local.dns_zones
    ns        = "ns1"
  })
}

resource "random_bytes" "tsig" {
  for_each = toset(var.dns_config.zones[*].name)
  length   = 32
}

data "cloudinit_config" "dns" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    merge_type   = "list(append)+dict(recurse_array)+str()"

    content = local.dns_cloudinit
  }
}

resource "incus_instance" "dns" {
  count = var.dns_config.replicas

  name     = "dns-0${count.index + 1}"
  profiles = [var.dns_config.profile]
  project  = var.project
  image    = local.ubuntu_24_04_cloud

  config = {
    "cloud-init.user-data" : data.cloudinit_config.dns.rendered
  }
}

output "tsig_keys" {
  sensitive = true
  value     = random_bytes.tsig
}
