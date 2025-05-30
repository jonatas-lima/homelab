server:
  rundir: "/run/knot"
  user: knot:knot
  listen: [ 0.0.0.0@53, ::1@53 ]

log:
  - target: syslog
    any: info

database:
    storage: "/var/lib/knot"

key:
  %{~ for zone in zones }
  - id: ${zone.name}.
    algorithm: hmac-sha256
    secret: ${zone.key}
  %{~ endfor }

# ACL que usa a chave e permite update da máquina local
acl:
  %{~ for zone in zones }
  - id: dynamic-update-${zone.name}
    key: ${zone.name}.
    action: update

  - id: allow-transfer-${zone.name}
    key: ${zone.name}.
    action: transfer
  %{~ endfor }

# Template para zonas (arquivo de zona padrão)
template:
  - id: default
    storage: "/var/lib/knot/zones"
    file: "%s.zone"

# Definição das zonas, com ACL para atualização dinâmica
zone:
  %{~ for zone in zones }
  - domain: ${zone.name}
    acl: [dynamic-update-${zone.name}, allow-transfer-${zone.name}]
  %{~ endfor }
