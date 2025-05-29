# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

# Full configuration options can be found at https://developer.hashicorp.com/vault/docs/configuration

ui = true

api_addr      = "https://<SERVER_ADDR>:8200"
cluster_addr  = "https://<SERVER_ADDR>:8201"
disable_mlock = true

storage "file" {
  path = "/opt/vault/data"
}

# HTTP listener
#listener "tcp" {
#  address = "0.0.0.0:8200"
#  tls_disable = 1
# }

# HTTPS listener
listener "tcp" {
  address            = "0.0.0.0:8200"
  tls_cert_file      = "/opt/vault/tls/vault-cert.pem"
  tls_key_file       = "/opt/vault/tls/vault-key.pem"
  tls_client_ca_file = "/opt/vault/tls/vault-ca.pem"
}

# TODO: Implement RAFT storage
