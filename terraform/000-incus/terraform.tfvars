nameservers = ["10.190.11.12"]

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
    type    = "ovn"
    config = {
      "ipv4.address" = "192.168.1.1/24"
      "ipv4.nat"     = "true"
      "ipv6.address" = "none"
      "network"      = "incusbr0"
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
