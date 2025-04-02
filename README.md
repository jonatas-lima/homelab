# Homelab

## Stacks

- [ ] Incus
- [ ] OVN
- [ ] LDAP
- [ ] Gitlab
- [ ] Vault
- [ ] Kubernetes
- [ ] Netbox

## Components

### Network

- Underlay: 10.220.0.0/24
- OVN: 10.190.0.0/16

### Machines

#### Partitioning

- **SSD**:
  - /boot/efi - 1GB
  - / - 250GB

- **HD**:
  - /data - 1.6TB
  - /var/log - 100GB

##### peter

| Model       | RAM  | CPU | IPv4         |
| -----       | ---  | --- | ----         |
| Laptop Dell | 16GB |  8  | 10.220.0.250 |

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

- Create a VLAN:

```bash
# /etc/netplan/
network:
    ...
    vlans:
      vlan0:
        id: 1
        link: enp2s0
        addresses: ["192.168.0.250/24"]
    ...
```
