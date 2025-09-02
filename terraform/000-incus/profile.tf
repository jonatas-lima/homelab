variable "profiles" {
  description = "Incus profiles define hardware configurations (flavors) for instances. Each profile can have multiple flavors with different CPU, memory, and storage configurations."
  type = list(object({
    name    = string
    network = string
    project = optional(string, "default")
    flavors = list(object({
      vcpus  = number
      memory = number
      storage = object({
        pool = optional(string, "default")
        size = number
      })
    }))
  }))
  default = []
}

variable "nameservers" {
  description = "DNS nameservers para os profiles"
  type        = map(list(string))
  default = {
    # infra = ["10.191.1.2"]
    apps = ["10.191.1.3"]
  }
}

locals {
  flattened_profiles_list = flatten([
    for profile in var.profiles : [
      for flavor in profile.flavors : {
        name    = profile.name
        project = coalesce(profile.project, "default")
        network = profile.network
        vcpus   = flavor.vcpus
        memory  = flavor.memory
        storage = flavor.storage
        key     = "${profile.name}-${flavor.vcpus}-${floor(flavor.memory / 1024)}-${flavor.storage.size}"
      }
    ]
  ])
  flattened_profiles = {
    for item in local.flattened_profiles_list : item.key => item
  }
}

resource "incus_profile" "this" {
  for_each = local.flattened_profiles

  name    = each.key
  project = try(incus_project.this[each.value.project].name, "default")

  config = merge({
    "migration.stateful" = true
    "limits.cpu"         = each.value.vcpus
    "limits.memory"      = "${each.value.memory}MB"
    },
    contains(keys(var.nameservers), each.value.project) ? {
      "user.network-config" = <<-EOT
        version: 2
        ethernets:
          enp5s0:
            dhcp4: true
            dhcp4-overrides:
              use-dns: false
            nameservers:
              addresses: ${jsonencode(var.nameservers[each.value.project])}
      EOT
    } : {}
  )

  device {
    type = "disk"
    name = "root"

    properties = {
      pool = each.value.storage.pool
      path = "/"
      size = "${each.value.storage.size}GB"
    }
  }

  device {
    type = "nic"
    name = "eth0"

    properties = {
      name    = "eth0"
      network = incus_network.this[each.value.network].name
    }
  }
}
