# Incus

This document provides installation and configuration instructions for Incus, which serves as the foundation for the homelab infrastructure.

## Overview

Incus is a container, network, storage and virtual machine manager (LXD/LXC fork):

## Installation

### Install Incus Daemon and CLI

1. Install Incus from the official repository:

    ```bash
    # Add the Incus repository
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://pkgs.zabbly.com/key.asc | sudo gpg --dearmor -o /etc/apt/keyrings/zabbly.gpg
    echo "deb [signed-by=/etc/apt/keyrings/zabbly.gpg] https://pkgs.zabbly.com/incus/stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/zabbly-incus-stable.list

    # Update package list and install
    sudo apt update
    sudo apt install incus
    ```

2. Add your user to the incus group:

    ```bash
    sudo usermod -aG incus $USER
    newgrp incus
    ```

3. Initialize Incus:

    ```bash
    sudo incus admin init
    ```

    Follow the interactive setup:
    - **Clustering**: Choose "no" for single-node setup
    - **Storage**: Select ZFS for better performance and snapshots
    - **Network**: Configure a bridge network
    - **Remote access**: Enable for Terraform integration

## OVN Network Setup

Set up Open Virtual Network (OVN):

### Install OVN Components

```bash
sudo apt install ovn-central ovn-common ovn-host

sudo systemctl enable --now ovn-central
sudo systemctl enable --now ovn-controller

sudo ovs-vsctl set open_vswitch . \
  external_ids:ovn-remote=unix:/run/ovn/ovnsb_db.sock \
  external_ids:ovn-encap-type=geneve \
  external_ids:ovn-encap-ip=127.0.0.1
```

### Access Control

1. At `peter`, generate the incus token:

    ```bash
    incus config trust add <me> # e.g: incus config trust add jonatas
    ```

1. At your local computer:

  ```bash
  incus remote add homelab 10.220.0.250 # paste the token from the previous step
  ```

## Integration with Terraform

The homelab infrastructure is managed through Terraform. Key integration points:

- **Provider Configuration**: Uses Incus REST API
- **Resource Management**: Automated instance lifecycle
- **Network Provisioning**: Dynamic OVN network creation
- **Profile Management**: Standardized resource allocation

For detailed Terraform configuration, see the infrastructure code in the `terraform/` directory.

## References

- [Official Incus Documentation](https://linuxcontainers.org/incus/docs/main/)
- [OVN Integration Guide](https://linuxcontainers.org/incus/docs/main/reference/network_ovn/)
- [Incus Terraform Provider](https://registry.terraform.io/providers/lxc/incus/latest/docs)
