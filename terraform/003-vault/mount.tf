variable "mounts" {
  type = list(object({
    path    = string
    type    = string
    options = optional(map(string), {})
  }))
  default = []
}

data "terraform_remote_state" "infra" {
  backend = "local"
  config = {
    path = "../001-infra/terraform.tfstate"
  }
}

resource "vault_mount" "guest" {
  type = "kv-v2"
  path = "guest"
}

resource "vault_mount" "core" {
  type = "kv-v2"
  path = "core"
}

resource "vault_kv_secret_v2" "environment" {
  mount = vault_mount.core.path

  name = "environment"

  data_json = jsonencode({
    DNS_UPDATE_KEYALGORITHM = "hmac-sha256"
    DNS_UPDATE_KEYNAME      = module.common.zones.root
    DNS_UPDATE_KEYSECRET    = data.terraform_remote_state.infra.outputs.tsig_keys[module.common.dns_domains.root].base64
    DNS_UPDATE_SERVER       = module.common.nameservers.primary.host
  })

  delete_all_versions = true
}

resource "vault_mount" "this" {
  for_each = { for mount in var.mounts : "${mount.path}_${mount.type}" => mount }

  path = each.value.path
  type = each.value.type

  options = each.value.options
}
