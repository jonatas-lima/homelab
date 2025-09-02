variable "devices" {
  description = "List of Tailscale devices to configure with routing"
  type = list(object({
    name   = string
    routes = optional(list(string), ["10.190.0.0/16", "10.191.0.0/16"])
  }))
  default = []
}

variable "root_node_config" {
  description = "Configuration for the root Tailscale node with exit node routing"
  type = object({
    device_name = optional(string, "peter")
    routes      = optional(list(string), ["10.190.0.0/16", "10.191.0.0/16", "0.0.0.0/0", "::/0"])
  })
  default = {}
}

locals {
  devices = { for device in var.devices : device.name => device }
}

data "tailscale_device" "this" {
  for_each = local.devices

  hostname = each.key
}

data "tailscale_device" "root" {
  hostname = var.root_node_config.device_name
}

resource "tailscale_device_authorization" "this" {
  for_each = local.devices

  device_id  = data.tailscale_device.this[each.key].node_id
  authorized = true
}

resource "tailscale_device_subnet_routes" "root" {
  device_id = data.tailscale_device.root.node_id
  routes    = var.root_node_config.routes
}
