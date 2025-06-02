provider:
  name: "rfc2136"

domainFilters:
  %{ for domain in domain_filters ~}
  - ${domain}
  %{ endfor ~}

logLevel: ${log_level}
logFormat: ${log_format}
txtPrefix: "external-dns-"
txtOwnerId: "k8s"
extraArgs:
  - "--source=gateway-httproute"
  - "--source=gateway-tlsroute"
  - "--source=gateway-tcproute"
  - "--source=gateway-udproute"
  - "--rfc2136-host=${nameserver_host}"
  - "--rfc2136-port=${nameserver_port}"
  - "--rfc2136-zone=${nameserver_zone}"
  - "--rfc2136-tsig-secret=${tsig_secret}"
  - "--rfc2136-tsig-secret-alg=hmac-sha256"
  - "--rfc2136-tsig-keyname=${tsig_keyname}"
  - "--rfc2136-tsig-axfr"

resources:
  ${indent(2, yamlencode(resources))}

serviceMonitor:
  enabled: true
