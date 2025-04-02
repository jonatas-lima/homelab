resource "incus_network" "this" {
  for_each = local.profiles

  name    = "${each.value.network.name_preffix}-${each.value.project}"
  project = try(incus_project.this[each.value.project].name, "default")
  type    = "ovn"

  config = {
    "bridge.mtu"   = "1500"
    "ipv4.address" = each.value.network.cidr
    "ipv4.dhcp"    = "true"
    "ipv4.nat"     = "false"
    "ipv6.address" = "none"
    "network"      = "incusbr0"
  }
}
