variable "projects" {
  description = "Incus Projects"
  type        = list(string)
  default     = []
}

resource "incus_project" "this" {
  for_each = toset(var.projects)

  name        = each.key
  description = "Managed by Terraform. Incus ${each.key} project."
}
