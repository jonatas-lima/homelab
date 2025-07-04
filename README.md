# Homelab

## Stacks

- [X] Incus
- [X] OVN
- [X] Kubernetes
- [X] LDAP
- [X] DNS
- [X] Vault
<!-- - [ ] Netbox -->

### Kubernetes stacks

- [X] ExternalDNS
- [ ] CertManager
- [ ] GatewayAPI
- [ ] Traefik
- [ ] ArgoCD or Flux?

## Components

### Network

- Underlay: 10.220.0.0/24
- OVNs:
  - `apps`: 10.190.0.0/24
  - `infra-core`: 10.190.0.0/24
  - `infra-apps`: 10.190.0.0/24

### Machines

| Hostname | Model       | RAM  | CPU | IPv4         |
| -------- | -----       | ---  | --- | ----         |
| **peter**    | Laptop Dell | 16GB |  8  | 10.220.0.250 |

#### Partitioning

- **SSD**:
  - /boot/efi - 1GB
  - / - 250GB

- **HD**:
  - /data - 1.6TB
  - /var/log - 100GB

- **Default user**: `jonatas`

## Bootstrap

- Login to server

```bash
ssh jonatas@10.220.0.250
```

- Install ssh server and add the ssh pub key:

```bash
sudo apt install -y openssh-server
echo "pubkey" >> ~/.ssh/authorized_keys
```

- Add `jonatas` as superuser:

```bash
echo "jonatas ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/jonatas.conf
```

### Required tools

- tfenv
- git
- incus cli
