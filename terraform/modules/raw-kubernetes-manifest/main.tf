variable "url" {
  description = "URL to download raw Kubernetes manifest file. The manifest should contain YAML resources that will be applied to the cluster."
  type        = string
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

resource "kubernetes_manifest" "this" {
  for_each = local.resources_list

  manifest = each.value
}
