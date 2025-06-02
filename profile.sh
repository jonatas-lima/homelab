#!/bin/bash

USER=$1

set -a

TF_VAR_ldap_bind_dn="cn=vaultadmin,ou=admin,ou=users,dc=uzbunitim,dc=me"
VAULT_ADDR=https://vault.uzbunitim.me:8200
KUBE_CONFIG_PATH=$KUBECONFIG
vault login -method=ldap username="$USER"

eval "$(vault kv get -format=json core/environment | jq -r '.data.data | to_entries[] | "\(.key)=\(.value | @sh)"')"

set +a
