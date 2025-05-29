#cloud-config
package_update: true
package_upgrade: true
packages:
  - curl
  - wget
  - tcpdump
  - bind9
  - bind9-utils
  - gnupg2
  - software-properties-common

write_files:
  - path: /tmp/vault.hcl
    permissions: 0644
    encoding: base64
    content: ${vault_hcl}

  %{~ for cert in certs }
  - path: /tmp/certs/${cert.name}
    permissions: ${cert.permissions}
    encoding: base64
    content: ${cert.pem}
  %{~ endfor }

  - path: /usr/local/bin/entrypoint.sh
    permissions: "0755"
    content: |
      #!/bin/bash

      set -ex

      curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
      apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
      apt update && apt install -y vault

      SERVER_ADDR=$(hostname -I | awk '{print $1}')
      sed -i "s/<SERVER_ADDR>/$SERVER_ADDR/g" /tmp/vault.hcl
      cp /tmp/vault.hcl /etc/vault.d/vault.hcl
      mv /tmp/certs/* /opt/vault/tls/

      chown -R vault:vault /etc/vault.d
      chown root:root /opt/vault/tls/vault-cert.pem /opt/vault/tls/vault-ca.pem
      chown root:vault /opt/vault/tls/vault-key.pem
      chmod 0644 /opt/vault/tls/vault-cert.pem /opt/vault/tls/vault-ca.pem
      chmod 0640 /opt/vault/tls/vault-key.pem

      systemctl enable --now vault

runcmd:
  - /usr/local/bin/entrypoint.sh
