profiles = [
  {
    name = "kubernetes"
    network = {
      name_preffix = "kubernetes"
      cidr         = "10.190.10.1/24"
    }
    pool = {
      name = "default"
      size = 20
    }
    resources = {
      vcpus  = 2
      memory = 4096
    }
    project = "prod"
  }
]
