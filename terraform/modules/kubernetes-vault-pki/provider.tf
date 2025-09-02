terraform {
  required_version = "~> 1.12.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.37.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.1.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4.5"
    }
  }
}
