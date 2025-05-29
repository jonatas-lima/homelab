variable "ldap_bind_password" {
  sensitive = true
  type      = string
}

variable "ldap_bind_dn" {
  type = string
}

variable "ldap_backend_config" {
  type = object({
    url         = string
    userdn      = string
    userattr    = optional(string, "cn")
    groupdn     = string
    groupattr   = optional(string, "cn")
    groupfilter = optional(string, "(&(objectClass=posixGroup)(memberUid={{.Username}}))")
  })
}

resource "vault_audit" "this" {
  type = "file"
  options = {
    file_path = "/opt/vault/audit.log"
  }
}

resource "vault_auth_backend" "ldap" {
  type = "ldap"
}

resource "vault_ldap_auth_backend" "this" {
  binddn       = var.ldap_bind_dn
  bindpass     = var.ldap_bind_password
  url          = var.ldap_backend_config.url
  userdn       = var.ldap_backend_config.userdn
  userattr     = var.ldap_backend_config.userattr
  groupdn      = var.ldap_backend_config.groupdn
  groupattr    = var.ldap_backend_config.groupattr
  groupfilter  = var.ldap_backend_config.groupfilter
  insecure_tls = true
}
