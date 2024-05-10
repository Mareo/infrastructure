terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "3.4.1"
    }
  }

  backend "s3" {
    key = "vault"
  }
}

locals {
  vault_addr = yamldecode(file("../config.yml")).vault_addr
}

provider "vault" {
  address = local.vault_addr
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
