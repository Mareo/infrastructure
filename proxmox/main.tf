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

  backend "s3" {
    key = "proxmox"
  }
}

provider "proxmox" {
  pm_api_url          = "https://athena.mareo.fr:8006/api2/json"
  pm_api_token_id     = "root@pam!terraform"
  pm_api_token_secret = trimspace(file("../secrets/proxmox_token"))
}

provider "dns" {
  update {
    server        = "mikros.mareo.fr"
    key_name      = "athena.mareo.fr."
    key_algorithm = "hmac-sha256"
    key_secret    = trimspace(file("../secrets/dns_key"))
  }
}

locals {
  dhcp_hosts_path = "../group_vars/proxmox.yml"
  sshkeys_path    = "../group_vars/all.yml"
}
