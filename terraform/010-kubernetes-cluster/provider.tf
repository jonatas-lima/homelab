terraform {
  required_version = "~> 1.12.0"
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "0.3.1"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "3.4.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
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
