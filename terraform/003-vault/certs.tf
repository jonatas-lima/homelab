resource "vault_mount" "pki" {
  path                      = "pki"
  type                      = "pki"
  default_lease_ttl_seconds = 8640000
  max_lease_ttl_seconds     = 8640000
}

resource "vault_mount" "pki_intermediate" {
  path = "pki-intermediate"
  type = "pki"
}

resource "vault_pki_secret_backend_root_cert" "this" {
  backend     = vault_mount.pki.path
  type        = "internal"
  common_name = "UzBunitim Vault Root CA"
  ttl         = "86400"
}

resource "vault_pki_secret_backend_issuer" "root" {
  issuer_name = "uzbunitim-root"
  backend     = vault_pki_secret_backend_root_cert.this.backend
  issuer_ref  = vault_pki_secret_backend_root_cert.this.issuer_id
}

resource "vault_pki_secret_backend_config_urls" "this" {
  backend = vault_mount.pki.path

  issuing_certificates = [
    "https://vault-01.uzbunitim.me:8200/v1/${vault_mount.pki.path}/ca"
  ]

  crl_distribution_points = [
    "https://vault-01.uzbunitim.me:8200/v1/${vault_mount.pki.path}/crl"
  ]
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  backend = vault_mount.pki_intermediate.path

  type        = "internal"
  common_name = "Uzbunitim Vault Root Intermediate CA"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
  backend    = vault_mount.pki.path
  csr        = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  issuer_ref = vault_pki_secret_backend_issuer.root.issuer_ref
  ttl        = "3153600"

  common_name = "Uzbunitim Vault Root Intermediate CA"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend     = vault_mount.pki_intermediate.path
  certificate = "${vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate}\n${vault_pki_secret_backend_root_cert.this.certificate}"
}

resource "vault_pki_secret_backend_role" "this" {
  backend          = vault_mount.pki_intermediate.path
  name             = "pki"
  ttl              = 31536000
  max_ttl          = 31536000
  allow_ip_sans    = true
  key_bits         = 4096
  key_type         = "rsa"
  allowed_domains  = ["uzbunitim.me"]
  allow_subdomains = true
}
