# Infra

## DNS

- Stack: bind9
- Number of nodes: 1
- Type: VM
- Flavor: 1vCPU, 1GB RAM
- Image: Ubuntu 24.04

**IMPORTANT ADR**: One TSIG key for all zones.

### How to

#### Add a new zone

1. Add your new zone in `/etc/bind/named.conf.local`:

    ```text
    zone "newzone.uzbunitim.com" {
      type master;
      file "/etc/bind/zones/db.newzone.uzbunitim.com";
      allow-transfer {
        key "uzbunitim.com.";
      };
      update-policy {
        grant uzbunitim.com. zonesub ANY;
      };
    };
    ```

1. Add your zone conf in `/etc/bind/zones/db.newzone.uzbunitin.com`:

    ```text
    $ORIGIN .

    $TTL 604800 ; 1 week
    newzone.uzbunitim.com  IN SOA ns1.newzone.uzbunitim.com. root.newzone.uzbunitim.com. (
        7          ; serial
        604800     ; refresh (1 week)
        86400      ; retry (1 day)
        2419200    ; expire (4 weeks)
        604800     ; minimum (1 week)
        )

      NS ns1.uzbunitim.com.
    ```

1. Restart `named`:

    ```bash
    systemctl restart named
    ```
