variable "public_nameservers" {
  description = "Public nameservers to use alongside internal resolver"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

resource "tailscale_dns_nameservers" "this" {
  nameservers = concat([module.common.nameservers.resolver.host], var.public_nameservers)
}

resource "tailscale_dns_preferences" "this" {
  magic_dns = true
}

resource "tailscale_dns_search_paths" "this" {
  search_paths = [
    module.common.dns_domains.root
  ]
}
