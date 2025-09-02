variable "image" {
  description = "Container image to use for the Kubernetes node. Uses Ubuntu 24.04 cloud image by default for compatibility with RKE2."
  type        = string
  default     = "images:ubuntu/24.04/cloud"
}

variable "project" {
  description = "Incus project where the Kubernetes node instance will be created. Projects provide isolation and resource management."
  type        = string
}

variable "profile" {
  description = "Incus profile defining the hardware configuration (CPU, memory, storage) for the Kubernetes node instance."
  type        = string
}

variable "node_config" {
  description = "RKE2-specific configuration for the Kubernetes node. Defines the node role, component settings, and customizations."
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
  description = "Common configuration shared across all nodes in the Kubernetes cluster for networking and security."
  type = object({
    advertise_address = string
    apiserver_dns     = optional(string)
    tls_san           = optional(list(string), [])
    bootstrap_server  = string
  })
}

variable "rke2_version" {
  description = "RKE2 (Rancher Kubernetes Engine 2) version to install on the node. Should match across all cluster nodes for compatibility."
  type        = string
  default     = "1.33.1+rke2"
}

variable "token" {
  description = "Shared secret token for node authentication and cluster joining."
  sensitive   = true
  type        = string
}

resource "random_id" "this" {
  byte_length = 4
}

locals {
  cloudinit = templatefile("${path.module}/templates/${var.node_config.role}-cloud-init.yaml.tpl", {
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

data "cloudinit_config" "this" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    merge_type   = "list(append)+dict(recurse_array)+str()"

    content = local.cloudinit
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
    "migration.stateful"   = "false"
  }

  dynamic "device" {
    for_each = { for device in var.additional_devices : device.name => device }
    content {
      name       = device.value.name
      type       = device.value.type
      properties = device.value.properties
    }
  }
}

variable "additional_devices" {
  type = list(object({
    name       = string
    type       = string
    properties = map(string)
  }))
  default = []
}
