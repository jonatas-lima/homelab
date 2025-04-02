# docs ref: https://docs.rke2.io/reference/server_config

# Common
config: /etc/rancher/rke2/config.yaml
debug: false
data-dir: "/var/lib/rancher/rke2"

# Listener
advertise-address: "${advertise_address}"
tls-san:
%{~ for entry in tls_san }
  - "${entry}"
%{~ endfor }
tls-san-security: true

# Networking
cluster-cidr: "172.16.0.0/13"
service-cidr: "172.28.0.0/16"
service-node-port-range: "30000-32767"
cluster-dns: "172.28.0.10"
cluster-domain: "cluster.local"
egress-selector-mode: "disabled"
servicelb-namespace: "kube-system"
cni: none

# Client
write-kubeconfig: "/etc/rancher/rke2/rke2.yaml"
write-kubeconfig-mode: "600"

# Cluster
token: "${token}"
%{~ if bootstrap }
server: "https://${bootstrap_server}:9345"
%{~ endif }

# Server Roles
disable-apiserver: false
disable-controller-manager: false
disable-scheduler: false
disable-etcd: false

# Flags
%{~ if length(kube_apiserver_args) > 0 }
kube-apiserver-arg:
%{~ for arg in kube_apiserver_args }
  - "${arg}"
%{~ endfor }
%{~ endif ~}
%{ if length(etcd_args) > 0 }
etcd-arg:
%{~ for arg in etcd_args }
  - "${arg}"
%{~ endfor }
%{~ endif }

# Components
disable:
%{~ for component in components_to_disable }
  - "${component}"
%{~ endfor }
disable-scheduler: false
disable-cloud-controller: true
disable-kube-proxy: true
enable-servicelb: false

# Agent/Node
%{~ if length(node_labels) > 0 }
node-label:
%{~ for label in node_labels }
  - "${label}"
%{~ endfor }
%{~ endif }
node-taint:
  - node-role.kubernetes.io/control-plane:NoSchedule
  - node-role.kubernetes.io/etcd:NoExecute

# Agent/Flags
%{~ if length(kubelet_args) > 0 }
kubelet-arg:
%{~ for arg in kubelet_args }
  - "${arg}"
%{~ endfor }
%{~ endif }
