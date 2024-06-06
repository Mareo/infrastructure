locals {
  k3s_vms = [
    {
      name      = "k3s-1.vm.ouranos.mareo.fr"
      tags      = ["ansible", "k3s_masters"]
      cores     = 16
      memory    = 40 * 1024
      disk_size = "128G"
    }
  ]
}

module "k3s" {
  source = "./vm"

  for_each = { for vm in local.k3s_vms : vm.name => vm }

  name        = each.value.name
  dns_zone    = "mareo.fr"
  target_node = "ouranos"
  onboot      = true

  pool = "ouranos"
  tags = each.value.tags

  cores   = each.value.cores
  memory  = each.value.memory
  balloon = each.value.memory

  template = "ubuntu-22.04-cloudinit-amd64"
  agent    = true

  sshkeys = local.sshkeys

  network_bridge  = "vmbr0"
  network_ip4     = local.dhcp_hosts[index(local.dhcp_hosts.*.name, each.value.name)].ip
  network_macaddr = local.dhcp_hosts[index(local.dhcp_hosts.*.name, each.value.name)].mac

  disk_storage = "rbd"
  disk_size    = each.value.disk_size
}
