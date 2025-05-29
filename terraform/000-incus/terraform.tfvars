profiles = [
  {
    name    = "kubernetes"
    network = "kubernetes"
    flavors = [
      {
        vcpus  = 2
        memory = 4096
        storage = {
          pool = "default"
          size = 20
        }
      }
    ]
    project = "apps"
  },
  {
    name    = "infra"
    network = "infra"
    flavors = [
      {
        vcpus  = 1
        memory = 1024
        storage = {
          pool = "default"
          size = 20
        }
      },
      {
        vcpus  = 2
        memory = 4096
        storage = {
          pool = "default"
          size = 20
        }
      }
    ]
    project = "infra"
  }
]

projects = ["apps", "infra"]

networks = [
  {
    name    = "kubernetes"
    project = "apps"
    type    = "bridge"
    config = {
      "ipv4.address" = "10.190.10.1/24"
      "ipv4.nat"     = "true"
      "ipv6.address" = "none"
    }
  },
  {
    name    = "infra",
    project = "infra"
    type    = "bridge"
    config = {
      "ipv4.address" = "10.190.11.1/24"
      "ipv4.nat"     = "true"
      "ipv6.address" = "none"
    }
  }
]
