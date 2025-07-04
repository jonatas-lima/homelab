variable "ldap_bind_password" {
  description = "Password for the LDAP bind user. This credential is used by Vault to authenticate with the LDAP server for user lookups and group membership queries."
  sensitive   = true
  type        = string
}

variable "ldap_bind_dn" {
  description = "Distinguished Name (DN) of the LDAP user account that Vault will use to bind to the LDAP server for authentication queries."
  type        = string
}

variable "ldap_backend_config" {
  description = "Configuration for Vault's LDAP authentication backend. Defines how Vault connects to and queries the LDAP server for user authentication and group membership."
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
