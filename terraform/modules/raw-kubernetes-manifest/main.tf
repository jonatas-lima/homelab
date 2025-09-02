variable "url" {
  description = "URL to download raw Kubernetes manifest file. The manifest should contain YAML resources that will be applied to the cluster."
  type        = string
}

variable "name" {
  description = "Name for the Helm release"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace to deploy resources"
  type        = string
  default     = "default"
}

data "http" "this" {
  url = var.url
}

locals {
  _resources_list             = split("---", data.http.this.response_body)
  need_to_strip_first_element = try(yamldecode(local._resources_list), null) == null
  start_index                 = local.need_to_strip_first_element ? 1 : 0
  end_index                   = length(local._resources_list)
  resources_list = {
    for resource in slice(local._resources_list, local.start_index, local.end_index) :
    "${yamldecode(resource)["apiVersion"]}_${yamldecode(resource)["kind"]}_${yamldecode(resource)["metadata"]["name"]}" => yamldecode(replace(resource, "/(?s:\nstatus:.*)$/", ""))
  }
}

resource "helm_release" "this" {
  name       = var.name
  chart      = "raw"
  version    = "0.3.2"
  repository = "https://dysnix.github.io/charts"
  namespace  = var.namespace

  values = [
    yamlencode({
      resources = values(local.resources_list)
    })
  ]
}
