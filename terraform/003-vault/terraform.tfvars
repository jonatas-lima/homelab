ldap_backend_config = {
  url         = "ldap://ldap.uzbunitim.me:3893"
  userattr    = "cn"
  groupdn     = "ou=users,dc=uzbunitim,dc=me"
  userdn      = "ou=users,dc=uzbunitim,dc=me"
  groupfilter = "(&(objectClass=posixGroup)(memberUid={{.Username}}))"
}

auth_backends = [
  {
    path = "kubernetes"
    type = "kubernetes"
  }
]

mounts = [
  {
    path = "kubernetes-secrets"
    type = "kv-v2"

    options = {
      version = "2"
      type    = "kv-v2"
    }
  }
]
