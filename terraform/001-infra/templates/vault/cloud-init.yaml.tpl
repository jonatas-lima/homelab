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

  - path: /tmp/vault-ext.cnf
    permissions: 0644
    content: |
      authorityKeyIdentifier=keyid,issuer
      basicConstraints=CA:FALSE
      keyUsage = digitalSignature, keyEncipherment
      extendedKeyUsage = serverAuth
      subjectAltName = @alt_names

      [alt_names]
      DNS.1 = localhost
      DNS.2 = ${common_name}
      IP.1 = 127.0.0.1
      IP.2 = <SERVER_ADDR>

  - path: /usr/local/bin/entrypoint.sh
    permissions: "0755"
    content: |
      #!/bin/bash

      set -ex

      curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
      apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
      apt update && apt install -y vault

      SERVER_ADDR=$(hostname -I | awk '{print $1}')
      sed -i "s/<SERVER_ADDR>/$SERVER_ADDR/g" /tmp/vault-ext.cnf
      sed -i "s/<SERVER_ADDR>/$SERVER_ADDR/g" /tmp/vault.hcl
      cp /tmp/vault.hcl /etc/vault.d/vault.hcl
      cp /tmp/vault-ext.cnf /opt/vault/tls

      openssl genrsa -out /opt/vault/tls/vault-ca.key 4096

      openssl req -x509 -new -nodes -key /opt/vault/tls/vault-ca.key \
        -sha256 \
        -days 3650 \
        -out /opt/vault/tls/vault-ca.pem \
        -subj "/C=BR/ST=Paraiba/L=Campina Grande/O=MyOrg/OU=Vault CA/CN=Vault Root CA"

      openssl req -new -key /opt/vault/tls/vault-key.pem \
        -out /opt/vault/tls/vault.csr \
        -subj "/C=BR/ST=Paraiba/L=Campina Grande/O=MyOrg/OU=Vault/CN=${common_name}"

      openssl x509 -req -in /opt/vault/tls/vault.csr \
        -CA /opt/vault/tls/vault-ca.pem \
        -CAkey /opt/vault/tls/vault-ca.key \
        -CAcreateserial \
        -out /opt/vault/tls/vault-cert.pem \
        -days 825 \
        -sha256 \
        -extfile /opt/vault/tls/vault-ext.cnf

      rm /opt/vault/tls/vault.csr /opt/vault/tls/vault-ca.srl

      chown -R vault:vault /etc/vault.d
      chown root:root /opt/vault/tls/vault-cert.pem /opt/vault/tls/vault-ca.pem
      chown root:vault /opt/vault/tls/vault-key.pem
      chmod 0644 /opt/vault/tls/vault-cert.pem /opt/vault/tls/vault-ca.pem
      chmod 0640 /opt/vault/tls/vault-key.pem

      systemctl enable --now vault

runcmd:
  - /usr/local/bin/entrypoint.sh
