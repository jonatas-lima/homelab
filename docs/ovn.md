# OVN

## Bootstrap

```bash
```

## Known issues

- Por algum motivo, o IP do LB usando MetalLB não é acessível de fora dos pods.

    ```bash
    # em peter
    arp -a
    ? (10.190.10.101) at <incomplete> on incusbr0
    ```

- Resolve com:

  ```bash
  # em peter
  arp -s 10.190.10.101 00:16:3e:63:72:34
  ```

- Limitar o uso de ips no MetalLB

- Em peter: `sudo ip route add 192.168.1.0/24 via 10.190.10.2`
