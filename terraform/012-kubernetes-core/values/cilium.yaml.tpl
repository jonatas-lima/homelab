MTU: ${ mtu }
k8sServiceHost: "${apiserver_endpoint}"
k8sServicePort: "6443"
ipam:
  mode: "cluster-pool"
  operator:
    clusterPoolIPv4PodCIDRList: ["172.16.0.0/13"]
    clusterPoolIPv4MaskSize: 24
kubeProxyReplacement: "true"

operator:
  enabled: true
  prometheus:
    enabled: true
    serviceMonitor:
      enabled: true

envoy:
  log:
    defaultLevel: ${log_level}

prometheus:
  enabled: true
