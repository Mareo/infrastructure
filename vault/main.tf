terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.22.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "3.3.2"
    }
  }

  backend "s3" {
    key = "vault"
  }
}

provider "vault" {
  address = yamldecode(file("../config.yml")).vault_addr
}

provider "dns" {
  update {
    server        = "mikros.mareo.fr"
    key_name      = "ouranos.mareo.fr."
    key_algorithm = "hmac-sha256"
    key_secret    = trimspace(file("../secrets/dns_key"))
  }
}

module "k8s-mareo-fr" {
  source = "./k8s.mareo.fr"
}
