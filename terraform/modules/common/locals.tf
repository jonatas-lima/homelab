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
      prod = "10.190.19.3"
    }
  }
  nameservers = {
    primary = {
      host = "10.190.11.2"
      port = "53"
    }
  }
  dns_domains = {
    root    = "uzbunitim.com"
    project = "${var.project}.uzbunitim.com"
  }
  zones = {
    root    = "${local.dns_domains.root}."
    project = "${var.project}.${local.dns_domains.root}."
  }
}
