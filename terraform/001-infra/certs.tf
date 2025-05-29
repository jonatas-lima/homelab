# locals {
#   one_year = 24 * 365
# }

# resource "tls_private_key" "ca" {
#   algorithm = "ed25519"
# }

# resource "tls_self_signed_cert" "ca" {
#   validity_period_hours = local.one_year
#   allowed_uses          = ["cert_signing", "crl_signing"]
#   is_ca_certificate     = true
#   private_key_pem       = tls_private_key.ca.private_key_pem
# }

# resource "tls_private_key" "ldap" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "tls_self_signed_cert" "ldap" {
#   dns_names = ["ldap.uzbunitim.me"]

#   private_key_pem       = tls_private_key.ldap.private_key_pem
#   validity_period_hours = local.one_year
# }
