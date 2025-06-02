variable "project" {
  description = "Incus project"
  default     = "default"
  type        = string
}

locals {
  bare_metal = {
    peter = {
      ipv4 = "10.220.0.250"
    }
  }
  endpoints = {
    kubernetes = {
      apps = "10.190.11.3"
    }
  }
  nameservers = {
    primary = {
      host = "10.191.1.2"
      port = "53"
    }
  }
  dns_domains = {
    root    = "uzbunitim.me"
    project = "${var.project}.uzbunitim.me"
  }
  zones = {
    root    = "${local.dns_domains.root}."
    project = "${var.project}.${local.dns_domains.root}."
  }
  vault = {
    core_mount = "core"
    address    = "https://vault.${local.dns_domains.root}:8200"
    pki = {
      mount              = "pki"
      intermediate_mount = "pki-intermediate"
      root_ca = {
        issuer_name = "uzbunitim-root"
        common_name = "UzBunitim Vault Root CA"
        ttl         = "86400"
      }
      intermediate_ca = {
        common_name = "Uzbunitim Vault Root Intermediate CA"
        ttl         = "86400"
      }
    }
  }
  # kubernetes = {
  #   ingress = {
  #     internal = {
  #       load_balancer_ip = "10.191.0.120"
  #     }
  #   }
  # }
}
