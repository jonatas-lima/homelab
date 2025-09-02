terraform {
  required_version = "~> 1.12.0"
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.21.1"
    }
  }
}

provider "tailscale" {}
