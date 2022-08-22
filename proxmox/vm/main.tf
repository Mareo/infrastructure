terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.11"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "3.2.3"
    }
  }
}
