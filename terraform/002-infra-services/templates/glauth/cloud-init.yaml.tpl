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

  %{~ for cert in certs }
  - path: /tmp/certs/${cert.name}
    encoding: base64
    permissions: ${cert.permissions}
    content: ${cert.pem}
  %{~ endfor }

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
      mv /tmp/certs/* /etc/glauth/tls
      chmod 640 /etc/glauth/config.cfg
      chown -R glauth:glauth /etc/glauth

      systemctl enable --now glauth

runcmd:
  - /usr/local/bin/entrypoint.sh
