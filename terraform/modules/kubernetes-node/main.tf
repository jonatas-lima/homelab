variable "image" {
  default = "images:ubuntu/24.04/cloud"
}

variable "project" {

}

variable "profile" {

}

variable "node_config" {
  type = object({
    role                  = string
    bootstrap             = optional(bool, false)
    kube_apiserver_args   = optional(map(string), {})
    kubelet_args          = optional(list(string), [])
    etcd_args             = optional(map(string), {})
    components_to_disable = optional(list(string), [])
    node_labels           = optional(map(string), {})
  })
}

variable "common_config" {
  type = object({
    advertise_address = string
    apiserver_dns     = optional(string)
    tls_san           = optional(list(string), [])
    bootstrap_server  = string
  })
}

variable "rke2_version" {

}

variable "token" {
  sensitive = true
  type      = string
}

resource "random_id" "this" {
  byte_length = 4
}

data "cloudinit_config" "this" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    merge_type   = "list(append)+dict(recurse_array)+str()"

    content = templatefile("${path.module}/templates/${var.node_config.role}-cloud-init.yaml.tpl", {
      common = templatefile("${path.module}/templates/common.yaml.tpl", {
        rke2_version       = var.rke2_version
        role               = var.node_config.role
        custom_addon_files = []
        node_config = base64encode(
          templatefile("${path.module}/templates/config/${var.node_config.role}.yaml.tpl", merge(
            var.node_config,
            var.common_config,
            { token = var.token }
            )
          )
        )
      })
      config        = var.node_config
      common_config = var.common_config
    })
  }
}

resource "incus_instance" "this" {
  lifecycle {
    replace_triggered_by = [random_id.this]
  }

  name     = "${var.node_config.role}-${random_id.this.hex}"
  profiles = [var.profile]
  project  = var.project
  image    = var.image
  type     = "virtual-machine"

  config = {
    "cloud-init.user-data" = data.cloudinit_config.this.rendered
  }
}

output "instance" {
  value = {
    name         = incus_instance.this.name
    ipv4_address = incus_instance.this.ipv4_address
    mac_address  = incus_instance.this.mac_address
  }
}
