#cloud-config
package_update: true
package_upgrade: true
packages:
  - curl
  - wget
  - tcpdump
  - bind9
  - bind9-utils

groups:
  - glauth

users:
  - name: glauth
    primary_group: glauth
    system: true
    shell: /usr/sbin/nologin

write_files:
  - path: /tmp/glauth.cfg
    permissions: 0644
    encoding: base64
    content: ${config_file}

  - path: /usr/lib/systemd/system/glauth.service
    permissions: 0644
    content: |
      [Unit]
      Description=GLAuth Lightweight LDAP Server
      After=network.target

      [Service]
      Type=simple
      User=glauth
      Group=glauth
      ExecStart=/usr/local/bin/glauth -c /etc/glauth/config.cfg
      Restart=on-failure
      LimitNOFILE=65536

      [Install]
      WantedBy=multi-user.target

  - path: /usr/local/bin/entrypoint.sh
    permissions: "0755"
    content: |
      #!/bin/bash

      set -ex
      mkdir -p /etc/glauth/tls
      wget https://github.com/glauth/glauth/releases/download/${version}/glauth-linux-amd64 -O /usr/local/bin/glauth
      chmod +x /usr/local/bin/glauth
      mv /tmp/glauth.cfg /etc/glauth/config.cfg
      chmod 640 /etc/glauth/config.cfg
      openssl req -x509 -newkey rsa:4096 -keyout /etc/glauth/tls/key.pem -out /etc/glauth/tls/crt.pem -days 365 -nodes -subj '/CN=${common_name}'
      chown -R glauth:glauth /etc/glauth

      systemctl enable --now glauth

runcmd:
  - /usr/local/bin/entrypoint.sh
