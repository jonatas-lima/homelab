terraform {
  required_providers {
    vault = {
      source  = "local/hashicorp/vault"
      version = "5.0.0-me"
    }
  }
}

provider "vault" {}
