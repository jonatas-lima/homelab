variable "glauth_config" {
  type = object({
    replicas    = optional(number, 1)
    version     = optional(string, "v2.4.0")
    profile     = optional(string, "infra-1-2-20")
    common_name = optional(string, "ldap.uzbunitim.me")
    server = object({
      ldap_port  = optional(number, 3893)
      ldaps_port = optional(number, 3894)
      tracing_config = optional(object({
        enabled = optional(bool, false)
      }), {})
      backend_config = optional(object({
        base_dn = string
        legacy  = optional(bool, false)
      }))
      users = optional(list(object({
        name        = string
        uid         = number
        primary_gid = number
        # home_dir     = string
        login_shell  = optional(string, "/bin/bash")
        pass_sha_256 = string
        capabilities = optional(list(object({
          action = string
          object = string
        })), [])
      })), [])
      groups = optional(list(object({
        name = string
        gid  = string
        capabilities = optional(list(object({
          action = string
          object = string
        })), [])
      })), [])
    })
  })
}

locals {
  config_file = templatefile("./templates/glauth/config.cfg.tpl", var.glauth_config.server)
  glauth_cloudinit = templatefile("./templates/glauth/cloud-init.yaml.tpl", {
    config_file = base64encode(local.config_file)
    version     = var.glauth_config.version
    common_name = var.glauth_config.common_name
  })
}

data "cloudinit_config" "glauth" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    merge_type   = "list(append)+dict(recurse_array)+str()"

    content = local.glauth_cloudinit
  }
}

resource "incus_instance" "glauth" {
  count = var.glauth_config.replicas

  name     = "glauth-0${count.index + 1}"
  image    = local.ubuntu_24_04_cloud
  project  = var.project
  profiles = [var.glauth_config.profile]

  config = {
    "cloud-init.user-data" : data.cloudinit_config.glauth.rendered
  }
}
