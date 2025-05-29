variable "profiles" {
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

locals {
  profiles = { for profile in var.profiles : profile.name => profile }
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

  config = {
    "migration.stateful" = true
    "limits.cpu"         = each.value.vcpus
    "limits.memory"      = "${each.value.memory}MB"
  }

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
      network = incus_network.this[each.value.network].name
    }
  }
}
