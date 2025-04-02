variable "control_plane" {
  type = object({
    replicas = optional(number, 1)
    profile  = optional(string, "kubernetes-2-4-20")
  })
  default = {
  }
}

variable "workers" {
  type = object({
    replicas = optional(number, 2)
    profile  = optional(string, "kubernetes-2-4-20")
  })
  default = {

  }
}

variable "rke2_version" {
  default = "v1.32.1+rke2r1"
}

locals {
  network                           = "${var.network}-${var.project}"
  apiserver_load_balancer_ipv4      = "10.190.19.3"
  control_plane_load_balancer_ports = [9345, 6443, 80]
  instance_port_mapping = flatten(
    [
      for instance in module.control_plane[*].instance : [
        for port in local.control_plane_load_balancer_ports : {
          port           = port
          name           = "${instance.name}-${port}"
          target_address = instance.ipv4_address
        }
      ]
    ]
  )
  backend_port_mapping = {
    for mapping in local.instance_port_mapping : mapping.port => mapping.name...
  }
}

resource "random_bytes" "token" {
  length = 32
}

module "control_plane" {
  count = var.control_plane.replicas

  source = "../modules/kubernetes-node"

  rke2_version = var.rke2_version
  project      = var.project
  profile      = var.control_plane.profile
  node_config = {
    role      = "control-plane"
    bootstrap = count.index == 1
    components_to_disable = [
      "rke2-ingress-nginx",
      "rke2-metrics-server",
      "rke2-coredns"
    ]
  }
  token = random_bytes.token.hex
  common_config = {
    advertise_address = local.apiserver_load_balancer_ipv4
    tls_san = [
      local.apiserver_load_balancer_ipv4
    ]
    bootstrap_server = local.apiserver_load_balancer_ipv4
  }
}

module "worker" {
  count = var.workers.replicas

  source = "../modules/kubernetes-node"

  rke2_version = var.rke2_version
  project      = var.project
  profile      = var.workers.profile
  node_config = {
    role = "worker"
    components_to_disable = [
      "rke2-ingress-nginx",
      "rke2-metrics-server",
      "rke2-coredns"
    ]
  }
  token = random_bytes.token.hex
  common_config = {
    advertise_address = local.apiserver_load_balancer_ipv4
    tls_san = [
      local.apiserver_load_balancer_ipv4
    ]
    bootstrap_server = local.apiserver_load_balancer_ipv4
  }
}

resource "incus_network_lb" "control_plane" {
  network        = local.network
  listen_address = local.apiserver_load_balancer_ipv4

  config = {
    healthcheck = true
  }

  dynamic "backend" {
    for_each = local.instance_port_mapping

    content {
      description    = "Backend for ${backend.value.name}"
      name           = backend.value.name
      target_address = backend.value.target_address
      target_port    = backend.value.port
    }
  }

  dynamic "port" {
    for_each = toset(local.control_plane_load_balancer_ports)
    content {
      description    = "Port ${port.value}/tcp"
      protocol       = "tcp"
      listen_port    = port.value
      target_backend = local.backend_port_mapping[port.value]
    }
  }
}
