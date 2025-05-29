resource "vault_mount" "guest" {
  type = "kv-v2"
  path = "guest"
}
