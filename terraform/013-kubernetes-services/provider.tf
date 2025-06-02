terraform {
  required_version = "~> 1.12.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.36.0"
    }
  }
}

provider "kubernetes" {}
