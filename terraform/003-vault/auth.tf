variable "auth_backends" {
  type = list(object({
    type = string
    path = string
  }))
  default = []
}

resource "vault_auth_backend" "this" {
  for_each = { for backend in var.auth_backends : "${backend.path}_${backend.type}" => backend }

  path = each.value.path
  type = each.value.type
}
