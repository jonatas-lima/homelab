variable "networks" {
  description = "Configuration for Incus networks. Each network defines networking infrastructure including OVN or bridge networks with custom configurations."
  type = list(object({
    name    = string
    project = string
    type    = string
    config  = map(string)
  }))
}

locals {
  networks = { for network in var.networks : network.name => network }
}

resource "incus_network" "this" {
  for_each = local.networks

  name    = each.key
  project = try(incus_project.this[each.value.project].name, "default")
  type    = each.value.type

  config = each.value.config
}
