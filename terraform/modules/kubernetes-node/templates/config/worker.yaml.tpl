# docs ref: https://docs.rke2.io/reference/linux_agent_config

# Common
config: /etc/rancher/rke2/config.yaml
debug: false
data-dir: "/var/lib/rancher/rke2"

# Cluster
token: "${token}"
server: "https://${bootstrap_server}:9345"

# Node
%{~ if length(node_labels) > 0 }
node-label:
%{~ for label in node_labels }
  - "${label}"
%{~ endfor }
%{~ endif }

# Runtime
private-registry: "/etc/rancher/rke2/registries.yaml"

# Components
%{~ if length(kubelet_args) > 0 }
kubelet-arg:
%{~ for arg in kubelet_args }
  - "${arg}"
%{~ endfor }
%{~ endif }
