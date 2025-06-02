project = "infra"

dns_config = {
  replicas = 1
  profile  = "infra-core-1-1-20"
  zones = [
    {
      name = "uzbunitim.me",
    }
  ]
}
