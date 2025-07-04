variable "control_plane" {
  description = "Configuration for Kubernetes control plane nodes."
  type = object({
    replicas = optional(number, 1)
    profile  = optional(string, "kubernetes-2-4-20")
  })
  default = {}
}

variable "workers" {
  description = "Configuration for Kubernetes worker nodes."
  type = object({
    replicas = optional(number, 2)
    profile  = optional(string, "kubernetes-2-4-20")
  })
  default = {}
}

variable "rke2_version" {
  description = "RKE2 (Rancher Kubernetes Engine 2) version to install."
  default     = "v1.33.1+rke2r1"
  type        = string
}

locals {
  network                           = "kubernetes"  # TODO: replace for a variable
  apiserver_load_balancer_ipv4      = "10.190.11.3" # TODO: replace for a variable or pull from "common"
  apiserver_dns                     = "apiserver.${module.common.dns_domains.root}"
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
  common_config = {
    advertise_address = local.apiserver_load_balancer_ipv4
    apiserver_dns     = local.apiserver_dns
    tls_san = [
      local.apiserver_load_balancer_ipv4,
      local.apiserver_dns
    ]
    bootstrap_server = local.apiserver_load_balancer_ipv4
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
  token         = random_bytes.token.hex
  common_config = local.common_config
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
  token         = random_bytes.token.hex
  common_config = local.common_config
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

resource "dns_a_record_set" "apiserver" {
  name      = "apiserver"
  zone      = module.common.zones.root
  addresses = [local.apiserver_load_balancer_ipv4]
}
