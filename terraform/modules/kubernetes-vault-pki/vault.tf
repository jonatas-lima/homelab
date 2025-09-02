variable "kubernetes_config" {
  description = "Kubernetes cluster connection configuration"
  type = object({
    ca_cert = string
    host    = string
  })
}

variable "vault_address" {
  description = "Vault server address for API calls"
  type        = string
}

variable "issuer_name" {
  description = "Name for the PKI issuer policy"
  type        = string
  default     = "pki-kubernetes-intermediate"
}

variable "signer_name" {
  description = "Vault PKI mount name for signing intermediate CA"
  type        = string
  default     = "pki-intermediate"
}

variable "vault_mount" {
  description = "Vault PKI mount path for certificates"
  type        = string
}

variable "vault_auth_backend" {
  description = "Vault Kubernetes auth backend name"
  type        = string
  default     = "kubernetes"
}

variable "ttl" {
  description = "Certificate TTL in seconds"
  type        = number
}

variable "key_bits" {
  description = "RSA key size in bits"
  type        = number
  default     = 2048
}

variable "allowed_domains" {
  description = "List of domains allowed for certificate issuance"
  type        = list(string)
}

variable "role_name" {
  description = "Name of the Vault PKI role"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for cert-manager service account"
  type        = string
}

variable "service_account_name" {
  description = "Name of the cert-manager service account"
  type        = string
}

locals {
  one_year_in_seconds = 60 * 60 * 24 * 365
}

data "http" "pki_intermediate_ca" {
  url = "${var.vault_address}/v1/${var.signer_name}/ca/pem"
}

resource "vault_pki_secret_backend_config_urls" "this" {
  backend = var.vault_mount

  issuing_certificates = [
    "${var.vault_address}/v1/${var.vault_mount}/ca",
  ]

  crl_distribution_points = [
    "${var.vault_address}/v1/${var.vault_mount}/crl",
  ]
}

resource "vault_pki_secret_backend_intermediate_cert_request" "this" {
  backend     = var.vault_mount
  type        = "internal"
  common_name = "UzBunitim Kubernetes CA"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "this" {
  backend              = var.signer_name
  csr                  = vault_pki_secret_backend_intermediate_cert_request.this.csr
  common_name          = "UzBunitim Kubernetes CA"
  exclude_cn_from_sans = true
  ttl                  = local.one_year_in_seconds * 3
}

resource "vault_pki_secret_backend_intermediate_set_signed" "this" {
  backend     = var.vault_mount
  certificate = "${vault_pki_secret_backend_root_sign_intermediate.this.certificate}\n${data.http.pki_intermediate_ca.response_body}"
}

resource "vault_pki_secret_backend_config_issuers" "this" {
  backend                       = var.vault_mount
  default                       = vault_pki_secret_backend_intermediate_set_signed.this.imported_issuers[0]
  default_follows_latest_issuer = true
}

resource "vault_pki_secret_backend_role" "cert_manager" {
  backend          = var.vault_mount
  name             = var.role_name
  issuer_ref       = vault_pki_secret_backend_intermediate_set_signed.this.imported_issuers[0]
  ttl              = var.ttl
  allow_ip_sans    = true
  key_bits         = var.key_bits
  allowed_domains  = var.allowed_domains
  allow_subdomains = true
}

resource "vault_policy" "vault_cluster_issuer" {
  name   = var.issuer_name
  policy = <<EOT
path "${var.vault_mount}*"                    { capabilities = ["read", "list"] }
path "${var.vault_mount}/sign/${vault_pki_secret_backend_role.cert_manager.name}"  { capabilities = ["create", "update"] }
path "${var.vault_mount}/issue/${vault_pki_secret_backend_role.cert_manager.name}" { capabilities = ["create"] }
EOT
}

resource "vault_kubernetes_auth_backend_config" "cert_manager" {
  backend            = var.vault_auth_backend
  kubernetes_host    = var.kubernetes_config.host
  kubernetes_ca_cert = var.kubernetes_config.ca_cert
  token_reviewer_jwt = kubernetes_secret_v1.service_account_token.data.token
  issuer             = "https://kubernetes.default.svc.cluster.local"
}

resource "vault_kubernetes_auth_backend_role" "cert_manager" {
  backend                          = var.vault_auth_backend
  bound_service_account_names      = [kubernetes_service_account_v1.this.metadata[0].name]
  bound_service_account_namespaces = [var.namespace]
  token_ttl                        = 60 # 1 minute
  token_policies                   = [vault_policy.vault_cluster_issuer.name]
  role_name                        = var.role_name
  audience                         = "vault://vault"
}
