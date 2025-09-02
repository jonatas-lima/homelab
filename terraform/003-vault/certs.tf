locals {
  one_year_in_seconds = 60 * 60 * 24 * 365
}

resource "vault_mount" "pki" {
  path                      = module.common.vault.pki.mount
  type                      = "pki"
  default_lease_ttl_seconds = 8640000
  max_lease_ttl_seconds     = local.one_year_in_seconds * 10
}

resource "vault_mount" "pki_intermediate" {
  path = module.common.vault.pki.intermediate_mount
  type = "pki"

  max_lease_ttl_seconds = local.one_year_in_seconds * 5
}

resource "vault_pki_secret_backend_root_cert" "this" {
  backend     = vault_mount.pki.path
  type        = "internal"
  common_name = module.common.vault.pki.root_ca.common_name
  ttl         = module.common.vault.pki.root_ca.ttl
}

resource "vault_pki_secret_backend_issuer" "root" {
  issuer_name = module.common.vault.pki.root_ca.issuer_name
  backend     = vault_pki_secret_backend_root_cert.this.backend
  issuer_ref  = vault_pki_secret_backend_root_cert.this.issuer_id
}

resource "vault_pki_secret_backend_config_urls" "this" {
  backend = vault_mount.pki.path

  issuing_certificates = [
    "${module.common.vault.address}/v1/${vault_mount.pki.path}/ca"
  ]

  crl_distribution_points = [
    "${module.common.vault.address}/v1/${vault_mount.pki.path}/crl"
  ]
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  backend = vault_mount.pki_intermediate.path

  type        = "internal"
  common_name = module.common.vault.pki.intermediate_ca.common_name
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
  backend    = vault_mount.pki.path
  csr        = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  issuer_ref = vault_pki_secret_backend_issuer.root.issuer_ref
  ttl        = module.common.vault.pki.intermediate_ca.ttl

  common_name = module.common.vault.pki.intermediate_ca.common_name
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend     = vault_mount.pki_intermediate.path
  certificate = "${vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate}\n${vault_pki_secret_backend_root_cert.this.certificate}"
}

resource "vault_pki_secret_backend_role" "this" {
  backend        = vault_mount.pki_intermediate.path
  name           = "pki"
  ttl            = module.common.vault.pki.intermediate_ca.ttl
  max_ttl        = module.common.vault.pki.intermediate_ca.ttl
  allow_ip_sans  = true
  key_bits       = 4096
  key_type       = "rsa"
  allow_any_name = true
}
