#cloud-config
package_update: true
package_upgrade: true
packages:
  - curl
  - jq
  - tcpdump
  - knot
  - knot-dnsutils
  - dnsutils

write_files:
  - path: /tmp/knot.conf
    encoding: base64
    permissions: 0644
    content: ${knot_conf}

  %{~ for zone in zones }
  - path: /tmp/${zone.name}.zone
    owner: root
    group: root
    content: |
      $ORIGIN ${zone.name}.
      $TTL	${zone.config.ttl}
      @	IN	SOA	${ns}.${zone.name}. root.${zone.name}. (
                  3		; Serial
            ${zone.config.refresh}		          ; Refresh
              ${zone.config.retry}		          ; Retry
            ${zone.config.expire}		            ; Expire
            ${zone.config.negative_cache_ttl} )	; Negative Cache TTL
      ;
      @	IN	NS	${ns}.${zone.name}.
      ${ns}.${zone.name}.	IN	A	<NS_HOST>
  %{~ endfor }
  - path: /usr/local/bin/entrypoint.sh
    permissions: "0755"
    content: |
      #!/bin/bash

      set -ex

      mkdir -p /var/lib/knot/zones
      NS_HOST=$(hostname -I | awk '{print $1}')
      %{ for zone in zones }
      sed -i "s/<NS_HOST>/$NS_HOST/g" /tmp/${zone.name}.zone
      mv /tmp/${zone.name}.zone /var/lib/knot/zones
      %{~ endfor }

      mv /tmp/knot.conf /etc/knot
      chown -R knot:knot /var/lib/knot
      chown -R knot:knot /etc/knot

      systemctl stop systemd-resolved
      systemctl disable systemd-resolved
      rm /etc/resolv.conf
      echo 'nameserver 8.8.8.8' > /etc/resolv.conf
      systemctl enable knot
      knotc reload
      systemctl restart knot

runcmd:
  - /usr/local/bin/entrypoint.sh
