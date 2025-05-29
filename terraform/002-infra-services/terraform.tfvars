project = "infra"

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
        capabilities = [
          {
            action = "search"
            object = "*"
          }
        ]
      },
      {
        name         = "vaultadmin"
        uid          = 10002
        primary_gid  = 11001
        pass_sha_256 = "8ec301803792c213fc728b75a2fd5af57c73156d8599c99cdfd94154cfb78e39"
        capabilities = [
          {
            action = "search"
            object = "*"
          }
        ]
      },
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
