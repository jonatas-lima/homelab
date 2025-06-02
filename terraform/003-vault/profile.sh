#!/bin/bash

set -a

TF_VAR_ldap_bind_password="***REMOVED***"
TF_VAR_ldap_bind_dn="cn=vaultadmin,ou=admin,ou=users,dc=uzbunitim,dc=me"

VAULT_ADDR="https://vault.uzbunitim.me:8200"
VAULT_TOKEN="***REMOVED***"

set +a
