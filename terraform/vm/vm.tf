resource "proxmox_vm_qemu" "vm" {
  name        = var.name
  target_node = var.target_node
  onboot      = var.onboot

  pool = var.pool != "" ? var.pool : null
  tags = join(",", var.tags)

  cores   = var.cores
  vcpus   = var.cores
  memory  = var.memory
  balloon = 512

  clone      = var.template
  full_clone = var.full_clone
  os_type    = "cloud-init"

  cloudinit_cdrom_storage = var.cloud_init_storage != "" ? var.cloud_init_storage : var.disk_storage
  ipconfig0               = var.network_gw4 != "" ? "gw=${var.network_gw4},ip=${var.network_ip4}" : "ip=dhcp"
  ciuser                  = "root"
  sshkeys                 = replace(join("\n", var.sshkeys), ":", "-")

  bios   = "seabios"
  boot   = "order=scsi0"
  scsihw = "virtio-scsi-pci"
  tablet = false
  agent  = var.agent ? 1 : 0

  serial {
    id   = 0
    type = "socket"
  }

  vga {
    type   = "serial0"
    memory = 0
  }

  network {
    model   = var.network_driver
    bridge  = var.network_bridge
    macaddr = var.network_macaddr
  }

  disk {
    type    = "scsi"
    ssd     = var.disk_ssd ? 1 : 0
    discard = var.disk_discard ? "on" : "off"
    storage = var.disk_storage
    size    = var.disk_size
  }

  lifecycle {
    ignore_changes = [
      boot
    ]
  }

}
