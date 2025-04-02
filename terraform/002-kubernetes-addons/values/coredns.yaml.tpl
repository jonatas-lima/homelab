autoscaler:
  enabled: ${autoscaler.enabled}
  coresPerReplica: ${autoscaler.cores_per_replica}
  nodesPerReplica: ${autoscaler.nodes_per_replica}
  min: ${autoscaler.min}
  max: ${autoscaler.max}

service:
  clusterIP: 172.28.0.10

prometheus:
  service:
    enabled: true
  monitor:
    enabled: true

servers:
- zones:
  - zone: .
  port: 53
  plugins:
  - name: errors
  # Serves a /health endpoint on :8080, required for livenessProbe
  - name: health
    configBlock: |-
      lameduck 10s
  # Serves a /ready endpoint on :8181, required for readinessProbe
  - name: ready
  # Required to query kubernetes API for data
  - name: kubernetes
    parameters: cluster.local in-addr.arpa ip6.arpa
    configBlock: |-
      pods insecure
      fallthrough in-addr.arpa ip6.arpa
      ttl 30
  # Serves a /metrics endpoint on :9153, required for serviceMonitor
  - name: prometheus
    parameters: 0.0.0.0:9153
  - name: forward
    parameters: . /etc/resolv.conf
  - name: cache
    parameters: ${cache_duration}
  - name: loop
  - name: reload
  - name: loadbalance
  %{~ if length(additional_plugins) > 0 ~}
  ${indent(2, yamlencode(additional_plugins))}
  %{~ endif ~}
