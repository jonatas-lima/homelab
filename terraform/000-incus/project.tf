resource "incus_project" "this" {
  for_each = toset(values(local.profiles)[*].project)

  name        = each.key
  description = "Managed by Terraform. Incus ${each.key} project."
}
