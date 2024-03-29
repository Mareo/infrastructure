terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "3.3.2"
    }
  }
}
