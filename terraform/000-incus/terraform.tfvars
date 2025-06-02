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
    name    = "infra-core"
    network = "infra-core"
    flavors = [
      {
        vcpus  = 1
        memory = 1024
        storage = {
          pool = "default"
          size = 20
        }
      },
    ]
    project = "infra"
  },
  {
    name    = "infra-apps"
    network = "infra-apps"
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
      "ipv4.address" = "10.191.0.1/24"
      "ipv4.nat"     = "true"
      "ipv6.address" = "none"
      "network"      = "incusbr0"
    }
  },
  {
    name    = "infra-core",
    project = "infra"
    type    = "ovn"
    config = {
      "ipv4.address" = "10.191.1.1/24"
      "ipv4.nat"     = "true"
      "ipv6.address" = "none"
      "network"      = "incusbr0"
    }
  },
  {
    name    = "infra-apps",
    project = "infra"
    type    = "ovn"
    config = {
      "ipv4.address" = "10.191.2.1/24"
      "ipv4.nat"     = "true"
      "ipv6.address" = "none"
      "network"      = "incusbr0"
    }
  }
]
