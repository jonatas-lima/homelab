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
  tolerations:
    - key: "node-role.kubernetes.io/control-plane"
      operator: Exists
    - key: "node-role.kubernetes.io/master" #deprecated
      operator: Exists
    - key: "node.kubernetes.io/not-ready"
      operator: Exists
    - key: node-role.kubernetes.io/etcd # TODO: Increase node number and remove this toleration
      operator: Exists
  prometheus:
    enabled: true
    serviceMonitor:
      enabled: true

envoy:
  securityContext:
    capabilities:
      keepCapNetBindService: true
  log:
    defaultLevel: ${log_level}

prometheus:
  enabled: true

gatewayAPI:
  enabled: true

l2announcements:
  enabled: true

externalIPs:
  enabled: true
