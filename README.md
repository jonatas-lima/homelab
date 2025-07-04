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

## Terraform Infrastructure

The homelab infrastructure is managed through Terraform modules in the `terraform/` directory. Each module represents a different layer of the infrastructure.

### Setup

1. Copy the sample configuration files:

   ```bash
   make config
   ```

2. Edit the configuration files with your actual values:
   - `profile.sh`: Environment variables and authentication settings
   - `private.sh`: Sensitive credentials (LDAP passwords, etc.)

### Deployment Order

The infrastructure must be deployed in the numerical order of the directories.

### Running Terraform

#### Manual Deployment

Navigate to each terraform directory and run:

```bash
cd terraform/000-incus
source ../profile.sh your-username
source ../private.sh
terraform init
terraform plan
terraform apply
```

#### Using Makefile

A Makefile is provided to simplify the deployment process:

```bash
# Deploy all infrastructure
make deploy

# Deploy specific module
make incus
make infra
make infra-services
make vault
make dns
make kubernetes-crds
make kubernetes-core
make kubernetes-services
```

### Configuration Files

- `profile.sh`: Main configuration file (excluded from git)
- `private.sh`: Sensitive credentials (excluded from git)
- `profile.sample.sh`: Template for profile.sh
- `private.sample.sh`: Template for private.sh
