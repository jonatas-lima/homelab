# OVN (Open Virtual Network)

This document explains how to configure and manage OVN networks in the homelab Incus environment.

## Overview

Open Virtual Network (OVN) provides advanced software-defined networking capabilities for the homelab infrastructure, including L4 load balancers provided by incus.

## Network Architecture

The homelab uses a tiered network approach:

```text
Physical Network (Host)
├── incusbr0 (Bridge Network) - 10.220.0.0/24
    ├── infra (OVN) - 10.190.10.0/24
    │   ├── DNS servers
    │   ├── Vault instances
    │   └── LDAP servers
    └── kubernetes (OVN) - 10.190.11.0/24
        ├── Control plane nodes
        ├── Worker nodes
        └── Service networks
```

### Adding Host Routes

After creating an OVN network, add routes on the physical host to enable connectivity:

```bash
# Get network configuration
cidr=$(incus network show <network-name> | yq e '.config["ipv4.address"]' -)
gw=$(incus network show <network-name> | yq e '.config["volatile.network.ipv4.address"]' -)

# Add route to host routing table
sudo ip route add "$cidr" via "$gw" dev incusbr0 proto kernel

# Example for kubernetes network
cidr=$(incus network show kubernetes | yq e '.config["ipv4.address"]' -)
gw=$(incus network show kubernetes | yq e '.config["volatile.network.ipv4.address"]' -)
sudo ip route add "$cidr" via "$gw" dev incusbr0 proto kernel
```

### Making Routes Persistent

To make routes persistent across reboots, add them to the network configuration:

#### Using Netplan

1. Edit the netplan configuration:

    ```bash
    sudo vim /etc/netplan/01-netcfg.yaml
    ```

2. Add routes to the configuration:

    ```yaml
    network:
      version: 2
      ethernets:
        enp0s3:  # Replace with your interface
          dhcp4: true
          routes:
            - to: 10.190.10.0/24
              via: 10.220.0.100  # Replace with actual gateway
              on-link: true
            - to: 10.190.11.0/24
              via: 10.220.0.101  # Replace with actual gateway
              on-link: true
    ```

3. Apply the configuration:

    ```bash
    sudo netplan apply
    ```

## References

- [OVN Architecture](http://www.openvswitch.org/support/dist-docs/ovn-architecture.7.html)
- [Incus OVN Documentation](https://linuxcontainers.org/incus/docs/main/reference/network_ovn/)
- [OVN Central Commands](http://www.openvswitch.org/support/dist-docs/ovn-nbctl.8.html)
