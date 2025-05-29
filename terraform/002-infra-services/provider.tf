terraform {
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "0.3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "3.4.2"
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

provider "dns" {}
