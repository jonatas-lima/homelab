variable "profiles" {
  type = list(object({
    name = string
    network = optional(object({
      name_preffix = string
      cidr         = string
    }))
    pool = object({
      name = optional(string, "default")
      size = number
    })
    project = optional(string, "default")
    resources = object({
      vcpus  = number
      memory = number
    })
  }))
  default = []
}

locals {
  profiles = { for profile in var.profiles : profile.name => profile }
}

resource "incus_profile" "this" {
  for_each = local.profiles

  name    = "${each.key}-${each.value.resources.vcpus}-${each.value.resources.memory / 1024}-${each.value.pool.size}"
  project = try(incus_project.this[each.value.project].name, "default")

  config = {
    "migration.stateful" = true
    "limits.cpu"         = each.value.resources.vcpus
    "limits.memory"      = "${each.value.resources.memory}MB"
  }

  device {
    type = "disk"
    name = "root"

    properties = {
      pool = each.value.pool.name
      path = "/"
      size = "${each.value.pool.size}GB"
    }
  }

  device {
    type = "nic"
    name = "eth0"

    properties = {
      network = incus_network.this[each.key].name
    }
  }
}
