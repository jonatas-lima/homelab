variable "project" {
  description = "Incus project"
  default     = "default"
  type        = string
}

locals {
  one_year_in_seconds = 60 * 60 * 24 * 365

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
    resolver = {
      host = "10.191.1.3"
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
        ttl         = local.one_year_in_seconds * 10
      }
      intermediate_ca = {
        common_name = "Uzbunitim Vault Root Intermediate CA"
        ttl         = local.one_year_in_seconds * 5
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
