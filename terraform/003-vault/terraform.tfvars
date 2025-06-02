ldap_backend_config = {
  url         = "ldap://ldap.uzbunitim.me:3893"
  userattr    = "cn"
  groupdn     = "ou=users,dc=uzbunitim,dc=me"
  userdn      = "ou=users,dc=uzbunitim,dc=me"
  groupfilter = "(&(objectClass=posixGroup)(memberUid={{.Username}}))"
}
