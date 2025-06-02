# OVN

## New Incus OVN networks

Ao criar uma rede OVN no Incus, um IP da rede pai (`incusbr0` no caso do homelab) vai ser escolhido para ser o gateway da rede. É necessário adicionar esse gateway nas rotas da(s) máquina(s) física(s).

```bash
cidr=$(incus network show kubernetes | yq e '.config["ipv4.address"]' -)
gw=$(incus network show kubernetes | yq e '.config["volatile.network.ipv4.address"]' -)

sudo ip route add "$cidr" via "$gw" dev incusbr0 proto kernel
```
