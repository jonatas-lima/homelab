terraform {
  required_version = "~> 1.12.0"
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "0.3.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.6"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}
