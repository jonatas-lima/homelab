terraform {
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "0.3.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.6"
    }
  }
}
