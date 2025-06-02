locals {
  incus_exec = "incus exec homelab:${module.control_plane[0].instance.name} --project ${var.project}"
}

resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "until (${local.incus_exec} -- ls >/dev/null); do echo waiting for instance to be up and running && sleep 5; done"
  }
}

resource "null_resource" "kubeconfig" {
  depends_on = [null_resource.wait]

  provisioner "local-exec" {
    command = "${local.incus_exec} -- sh -c 'until (ls /etc/rancher/rke2/rke2-remote.yaml >/dev/null 2>&1); do echo waiting for rke2 to start && sleep 10; done'"
  }
  provisioner "local-exec" {
    command = "${local.incus_exec} -- cat /etc/rancher/rke2/rke2-remote.yaml > /tmp/kubeconfig.yml"
  }
}

output "control_plane" {
  value = module.control_plane[*].instance
}

output "worker" {
  value = module.worker[*].instance
}

output "dns" {
  value = dns_a_record_set.apiserver
}
