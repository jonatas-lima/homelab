variable "project" {
  description = "Incus project"
  default     = "default"
}

locals {
  bare_metal = {
    peter = {
      ipv4 = "10.220.0.250"
    }
  }
  endpoints = {
    kubernetes = {
      prod = "10.190.10.3"
    }
  }
  nameservers = {
    primary = {
      host = "10.190.11.12"
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
}
