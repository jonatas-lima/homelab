# variable "vault_config" {
#   type = object({
#     replicas = optional(number, 1)
#     profile  = optional(string, "infra-1-2-20")
#     server = object({
#       ldap_port  = optional(number, 3893)
#       ldaps_port = optional(number, 3894)
#       tracing_config = optional(object({
#         enabled = optional(bool, false)
#       }), {})
#       backend_config = optional(object({
#         base_dn = string
#         legacy  = optional(bool, false)
#       }))
#       users = optional(list(object({
#         name         = string
#         uid          = number
#         primary_gid  = number
#         home_dir     = string
#         pass_sha_256 = string
#         capabilities = optional(list(object({
#           action = string
#           object = string
#         })), [])
#       })), [])
#       groups = optional(list(object({
#         name = string
#         gid  = string
#         capabilities = optional(list(object({
#           action = string
#           object = string
#         })), [])
#       })), [])
#     })
#   })
# }

# locals {
#   config_file = templatefile("./templates/vault/config.cfg", var.vault_config.server)
#   vault_cloudinit = templatefile("./templates/vault/cloud-init.yaml.tpl", {
#     config_file = base64encode(local.config_file)
#     common_name = "ldap.uzbunitim.me"
#   })
# }

# data "cloudinit_config" "vault" {
#   gzip          = false
#   base64_encode = false

#   part {
#     filename     = "cloud-config.yaml"
#     content_type = "text/cloud-config"
#     merge_type   = "list(append)+dict(recurse_array)+str()"

#     content = local.vault_cloudinit
#   }
# }

# resource "incus_instance" "vault" {
#   count = var.vault_config.replicas

#   name = "vault-0${count.index + 1}"

#   config = {
#     "cloud-init.user-data" : data.cloudinit_config.vault.rendered
#   }
# }
