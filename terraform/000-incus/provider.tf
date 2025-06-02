terraform {
  required_version = "~> 1.12.0"
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "0.3.0"
    }
  }
}

provider "incus" {
  accept_remote_certificate = true

  dynamic "remote" {
    for_each = module.common.machines

    content {
      name    = remote.key
      address = remote.value.ipv4
      scheme  = "https"
    }
  }
}
