terraform {
  required_version = "~> 1.12.0"
  required_providers {
    dns = {
      source  = "hashicorp/dns"
      version = "3.4.2"
    }
  }
}

provider "dns" {}
