variable "storage_pools" {
  type = list(object({
    name   = string
    driver = optional(string, "btrfs")
    config = optional(map(string), {})
  }))
  default = [
    {
      name = "kubernetes"
      config = {
        source = "/data"
      }
    }
  ]
}

resource "incus_storage_pool" "this" {
  for_each = { for storage_pool in var.storage_pools : storage_pool.name => storage_pool }

  name   = each.key
  driver = each.value.driver
  config = each.value.config
}
