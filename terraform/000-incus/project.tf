variable "projects" {
  description = "List of Incus project names to create. Projects provide isolation and resource management for containers and VMs."
  type        = list(string)
  default     = []
}

resource "incus_project" "this" {
  for_each = toset(var.projects)

  name        = each.key
  description = "Managed by Terraform. Incus ${each.key} project."
}
