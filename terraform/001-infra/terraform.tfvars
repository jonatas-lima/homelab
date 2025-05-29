project = "infra"

network = "infra"

dns_config = {
  replicas = 1
  zones = [
    {
      name = "uzbunitim.me",
    },
    {
      name = "dev.uzbunitim.me",
    }
  ]
}

glauth_config = {
  profile  = "infra-1-1-20"
  replicas = 1
  server = {
    backend_config = {
      base_dn = "dc=uzbunitim,dc=me"
    }
    users = [
      {
        name         = "jonatas"
        pass_sha_256 = "5237c4f3ad1889f3c02d96227306a42d312e3762835307815cc5afe8aa2303b8"
        uid          = 10001
        primary_gid  = 11001
      },
      # {
      #   name = "samuel"
      # }
    ]
    groups = [
      {
        name = "admin"
        gid  = "11001"
      },
      {
        name = "guest"
        gid  = "11002"
      }
    ]
  }
}
