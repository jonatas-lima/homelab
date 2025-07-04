# tflint-ignore: all
variable "project" {
  description = "Name of the Incus project for resource isolation and management. Projects provide boundaries for containers, VMs, networks, and storage."
  type        = string
}
