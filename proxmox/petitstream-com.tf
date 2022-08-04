locals {
  petitstream_vms = [
    {
      name      = "petitstream.vm.athena.mareo.fr"
      tags      = [""]
      cores     = 4
      memory    = 4 * 1024
      disk_size = "64G"
    }
  ]
}

module "petitstream" {
  source = "./vm"

  for_each = { for vm in local.petitstream_vms : vm.name => vm }

  name        = each.value.name
  dns_zone    = "mareo.fr"
  target_node = "athena"
  onboot      = true

  pool = "athena"
  tags = each.value.tags

  cores  = each.value.cores
  memory = each.value.memory

  template = "ubuntu-22.04-cloudinit-amd64"

  sshkeys = local.sshkeys

  network_bridge  = "vmbr0"
  network_ip4     = local.dhcp_hosts[index(local.dhcp_hosts.*.name, each.value.name)].ip
  network_macaddr = local.dhcp_hosts[index(local.dhcp_hosts.*.name, each.value.name)].mac

  disk_storage = "rbd"
  disk_size    = each.value.disk_size
}
