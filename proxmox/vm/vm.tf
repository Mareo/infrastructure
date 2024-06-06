resource "proxmox_vm_qemu" "vm" {
  name             = var.name
  qemu_os          = "other"
  target_node      = var.target_node
  onboot           = var.onboot
  vm_state         = "running"
  automatic_reboot = false

  pool = var.pool != "" ? var.pool : null
  tags = join(";", var.tags)

  cores   = var.cores
  vcpus   = var.cores
  memory  = var.memory
  balloon = var.balloon

  clone      = var.template
  full_clone = var.full_clone
  os_type    = "cloud-init"

  ipconfig0 = var.network_gw4 != "" ? "gw=${var.network_gw4},ip=${var.network_ip4}" : "ip=dhcp"
  ciuser    = "root"
  sshkeys   = replace(join("\n", var.sshkeys), ":", "-")

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

  disks {
    ide {
      ide2 {
        cloudinit {
          storage = var.cloud_init_storage != "" ? var.cloud_init_storage : var.disk_storage
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          emulatessd = var.disk_ssd
          discard    = var.disk_discard
          storage    = var.disk_storage
          size       = var.disk_size
          iothread   = false
          readonly   = false
          replicate  = true
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      boot
    ]
  }

}
