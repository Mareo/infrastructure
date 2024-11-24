terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc5"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "3.4.2"
    }
  }
}
