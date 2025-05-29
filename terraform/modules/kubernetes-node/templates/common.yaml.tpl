#cloud-config
package_update: true
package_upgrade: true
packages:
- curl
- jq
- tcpdump

write_files:
- path: /usr/local/bin/wait-for-node-ready.sh
  permissions: "0755"
  owner: root:root
  content: |
    #!/bin/sh
    until (curl -sL http://localhost:10248/healthz) && [ $(curl -sL http://localhost:10248/healthz) = "ok" ];
      do sleep 10 && echo "Wait for $(hostname) kubelet to be ready"; done;
- path: /usr/local/bin/install-or-upgrade-rke2.sh
  permissions: "0755"
  owner: root:root
  content: |
    #!/bin/sh

    # Fetch target and actual version if already installed
    export INSTALL_RKE2_VERSION=${rke2_version}
    %{ if role == "worker" ~}
    export INSTALL_RKE2_TYPE=agent
    %{ endif ~}
    which rke2 >/dev/null 2>&1 && RKE2_VERSION=$(rke2 --version|head -1|cut -f 3 -d " ")

    # Install or upgrade
    if ([ -z "$RKE2_VERSION" ]) || ([ -n "$INSTALL_RKE2_VERSION" ] && [ "$INSTALL_RKE2_VERSION" != "$RKE2_VERSION" ]); then
      curl -sfL https://get.rke2.io | sh -
    fi
- path: /etc/rancher/rke2/config.yaml
  permissions: "0600"
  owner: root:root
  encoding: base64
  content: ${node_config}
%{~ if role == "control-plane" ~}
%{~ for config in custom_addon_files }
- path: /var/lib/rancher/rke2/server/manifests/${config.name}-config.yaml
  permissions: "0644"
  owner: root:root
  encoding: base64
  content: ${config.file}
%{~ endfor }
%{~ endif }
