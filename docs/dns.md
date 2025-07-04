# DNS Configuration

This document explains how to configure client machines to use the homelab DNS server for name resolution.

## Overview

The homelab DNS infrastructure uses Knot DNS server running on Incus containers. The DNS server provides:

- Local domain resolution for homelab services
- Integration with external DNS providers via ExternalDNS
- TSIG-authenticated dynamic DNS updates
- Split-horizon DNS for internal and external queries

## Configuring DNS Resolution

### Option 1: Using systemd-resolved (Recommended)

For systemd-based Linux distributions, configure systemd-resolved to use the homelab DNS:

1. Edit the systemd-resolved configuration:

    ```bash
    sudo vim /etc/systemd/resolved.conf
    ```

2. Add or modify these lines:

    ```ini
    [Resolve]
    DNS=<HOMELAB_DNS_IP>
    FallbackDNS=1.1.1.1 8.8.8.8
    Domains=~uzbunitim.me ~infra.uzbunitim.me ~apps.uzbunitim.me
    ```

3. Restart the systemd-resolved service:

    ```bash
    sudo systemctl restart systemd-resolved
    ```

4. Verify the configuration:

    ```bash
    systemd-resolve --status
    ```

### Option 2: Router Configuration

Configure your router/DHCP server to distribute the homelab DNS IP automatically:

1. Access your router's admin interface
2. Navigate to DHCP/DNS settings
3. Set the primary DNS server to your homelab DNS IP
4. Set secondary DNS servers to public resolvers (1.1.1.1, 8.8.8.8)

## Testing DNS Resolution

Verify that DNS resolution is working correctly:

```bash
# Test internal domain resolution
nslookup vault.uzbunitim.me

# Test external domain resolution
nslookup google.com

# Test reverse DNS lookup
nslookup <HOMELAB_SERVICE_IP>
```

## Troubleshooting

### DNS Resolution Not Working

1. Check if the DNS server is running:

    ```bash
    ping <HOMELAB_DNS_IP>
    ```

2. Verify DNS service status:

    ```bash
    dig @<HOMELAB_DNS_IP> vault.uzbunitim.me
    ```

3. Check systemd-resolved status:

    ```bash
    systemd-resolve --status
    systemctl status systemd-resolved
    ```

### Fallback to Public DNS

If the homelab DNS is unavailable, the system should automatically fallback to public DNS servers configured in the FallbackDNS setting.

### Cache Issues

Clear DNS cache if you're experiencing resolution issues:

```bash
# systemd-resolved
sudo systemd-resolve --flush-caches

# dnsmasq
sudo systemctl restart dnsmasq

# NetworkManager
sudo systemctl restart NetworkManager
```

## Security Considerations

- The homelab DNS server uses TSIG keys for authenticated updates
- Internal zones are not exposed to external queries
- DNS over TLS (DoT) can be configured for enhanced security
- Consider implementing DNS filtering for malware protection
