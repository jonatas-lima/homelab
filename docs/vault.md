# HashiCorp Vault Configuration

This document provides guidance for initializing, configuring, and managing HashiCorp Vault in the homelab environment.

## Overview

HashiCorp Vault serves as the centralized secret management and PKI solution for the homelab infrastructure.

## Initial Setup

### Operator Initialization

After the Terraform deployment completes, initialize Vault with a single unseal key for homelab simplicity:

```bash
# Set the CA certificate path
export VAULT_CACERT=/opt/vault/tls/vault-ca.pem
export VAULT_ADDR=https://vault.uzbunitim.me:8200

# Initialize Vault with single key (not recommended for production, but since it is a homelab...)
vault operator init -key-threshold=1 -key-shares=1
```

**Important**: Save the output containing the unseal key and root token securely. You'll need these for future operations.

### Unsealing Vault

Unseal Vault using the key from initialization:

```bash
# Unseal Vault (required after each restart)
vault operator unseal <UNSEAL_KEY>

# Check seal status
vault status
```

## References

- [Vault Documentation](https://www.vaultproject.io/docs)
- [Vault API Reference](https://www.vaultproject.io/api)
- [Vault PKI Secrets Engine](https://www.vaultproject.io/docs/secrets/pki)
- [Vault LDAP Auth Method](https://www.vaultproject.io/docs/auth/ldap)
