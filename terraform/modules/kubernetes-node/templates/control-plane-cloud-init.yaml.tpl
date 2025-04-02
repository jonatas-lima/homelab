${common}

runcmd:
  - /usr/local/bin/install-or-upgrade-rke2.sh
  %{~ if config.bootstrap ~}
  - [ sh, -c, '[ "$(hostname | rev | cut -d"-" -f1 | rev)" = 01 ] && sed -i "/^server:/d" /etc/rancher/rke2/config.yaml']
  - [ sh, -c, '[ "$(hostname | rev | cut -d"-" -f1 | rev)" != 01 ] && until (curl -ksS -m 5 -o /dev/null https://${common_config.bootstrap_server}:6443); do echo Wait for master node && sleep 10; done;']
  %{~ endif ~}
  - systemctl enable rke2-server.service
  - systemctl start rke2-server.service
  - [ sh, -c, 'until [ -f /etc/rancher/rke2/rke2.yaml ]; do echo Waiting for rke2 to start && sleep 10; done;' ]
  - [ sh, -c, 'until [ -x /var/lib/rancher/rke2/bin/kubectl ]; do echo Waiting for kubectl bin && sleep 10; done;' ]
  - cp /etc/rancher/rke2/rke2.yaml /etc/rancher/rke2/rke2-remote.yaml
  - KUBECONFIG=/etc/rancher/rke2/rke2-remote.yaml /var/lib/rancher/rke2/bin/kubectl config set-cluster default --server https://${common_config.advertise_address}:6443
  - KUBECONFIG=/etc/rancher/rke2/rke2-remote.yaml /var/lib/rancher/rke2/bin/kubectl config rename-context default peter
