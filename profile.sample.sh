#!/bin/bash

USER=${1:-"your-username"}

set -a

TF_VAR_ldap_bind_dn="cn=vaultadmin,ou=admin,ou=users,dc=uzbunitim,dc=me"
TF_VAR_ldap_bind_password="your-ldap-password"
VAULT_ADDR="https://vault.uzbunitim.me:8200"
VAULT_TOKEN="your-vault-token"

DNS_UPDATE_KEYALGORITHM="hmac-sha256"
DNS_UPDATE_KEYNAME="uzbunitim.me."
DNS_UPDATE_KEYSECRET="your-dns-secret"
DNS_UPDATE_SERVER="10.191.1.2"
DNS_UPDATE_TRANSPORT="tcp"

KUBE_CONFIG_PATH="$KUBECONFIG"

set +a

echo "$VAULT_LDAP_PASSWORD" | vault login -method=ldap username="$USER" -

eval "$(vault kv get -format=json core/environment | jq -r '.data.data | to_entries[] | "\(.key)=\(.value | @sh)"')"
