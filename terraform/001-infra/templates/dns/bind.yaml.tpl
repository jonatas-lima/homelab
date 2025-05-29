#cloud-config
package_update: true
package_upgrade: true
packages:
  - curl
  - jq
  - tcpdump
  - bind9
  - bind9-utils
  - gnutls
  - libedit
  - liburcu
  - lmdb

write_files:
  - path: /usr/local/bin/generate_tsig.sh
    permissions: 0755
    content: |
      #!/bin/bash

      set -ex

      tsig-keygen -a hmac-sha256 $1

  - path: /tmp/named.conf.options
    content: |
      acl "trusted" {
        %{~ for trust in trusted }
        ${trust};
        %{ endfor }
      };
      options {
        directory "/var/cache/bind";

        recursion yes;
        allow-recursion { trusted; };
        listen-on { <NS_HOST>; };
        allow-transfer { none; };

        forwarders {
                8.8.8.8;
                8.8.4.4;
        };
      };
  - path: /tmp/named.conf.local
    owner: root
    group: root
    content: |
      %{~ for zone in zones }
      zone "${zone.name}" {
        type master;
        file "/etc/bind/zones/db.${zone.name}";
        allow-transfer {
          key "${zone.name}.";
        };
        update-policy {
          grant ${zone.name}. zonesub ANY;
        };
      };

      zone "<NS_REVERSE>.in-addr.arpa" {
        type master;
        file "/etc/bind/zones/db.<NS_REVERSE>";
      };
      %{~ endfor }
  %{~ for zone in zones }
  - path: /tmp/db.${zone.name}
    owner: root
    group: root
    content: |
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

  - path: /tmp/db.${zone.name}.rev
    content: |
      $TTL	${zone.config.ttl}
      @	IN	SOA	${zone.name}. root.${zone.name}. (
                  3		; Serial
            ${zone.config.refresh}		          ; Refresh
              ${zone.config.retry}		          ; Retry
            ${zone.config.expire}		            ; Expire
            ${zone.config.negative_cache_ttl} )	; Negative Cache TTL
      ;
      @	IN	NS	${zone.name}.
      <NS_REVERSE>	IN	PTR	${zone.name}.
  %{~ endfor }
  - path: /usr/local/bin/entrypoint.sh
    permissions: "0755"
    content: |
      #!/bin/bash

      set -ex
      mkdir -p /etc/bind/zones
      NS_HOST=$(hostname -I | tr -d ' ')
      NS_REVERSE=$(hostname -I | rev | cut -d. -f1-2 | tr -d ' ')
      sed -i "s/<NS_REVERSE>/$NS_REVERSE/g" /tmp/named.conf.local
      sed -i "s/<NS_HOST>/$NS_HOST/g" /tmp/named.conf.options
      %{ for zone in zones }
      /usr/local/bin/generate_tsig.sh "${zone.name}." >> /tmp/named.conf.local
      sed -i "s/<NS_HOST>/$NS_HOST/g" /tmp/db.${zone.name}
      sed -i "s/<NS_REVERSE>/$NS_REVERSE/g" /tmp/db.${zone.name}.rev
      mv /tmp/db.${zone.name} /etc/bind/zones/
      mv /tmp/db.${zone.name}.rev /etc/bind/zones/db.$NS_REVERSE
      %{~ endfor }
      mv /tmp/named.conf.local /etc/bind/
      mv /tmp/named.conf.options /etc/bind

      systemctl enable named
      systemctl restart named

runcmd:
  - /usr/local/bin/entrypoint.sh
