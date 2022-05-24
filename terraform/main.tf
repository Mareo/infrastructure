terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.10"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "3.2.3"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://athena.mareo.fr:8006/api2/json"
  pm_api_token_id     = "root@pam!terraform"
  pm_api_token_secret = "43bad468-f5d7-48fd-9528-98217954d88f"

  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
  pm_debug      = true
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}

provider "dns" {
  update {
    server        = "prometheus.mareo.fr"
    key_name      = "athena.mareo.fr."
    key_algorithm = "hmac-sha256"
    key_secret    = "SmkBx0fmqT2VRUl/eZrQooGCnsHJNvLv47ddCLthXQQ="
  }
}

locals {
  dhcp_hosts_path = "../group_vars/proxmox.yml"
  sshkeys_path    = "../group_vars/all.yml"
}
