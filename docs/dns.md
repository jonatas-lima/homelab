# DNS

## Apontando para o DNS do homelab

1. Adicione o NS como resolver primário:

    ```bash
    vim /etc/systemd/resolved.conf
    # Adicionar essas linhas
    # DNS=<IP do nameserver>
    # FallbackDNS=10.220.0.1
    ```

1. Reinicie o serviço de DNS:

    ```bash
    systemctl restart systemd-resolved
    ```
