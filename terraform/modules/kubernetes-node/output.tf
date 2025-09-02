output "instance" {
  value = {
    name         = incus_instance.this.name
    ipv4_address = incus_instance.this.ipv4_address
    mac_address  = incus_instance.this.mac_address
  }
}

output "cloudinit" {
  value = local.cloudinit
}
