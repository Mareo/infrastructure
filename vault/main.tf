terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    tls = {
      source = "hashicorp/tls"
      version = "3.4.0"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "3.2.3"
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
    server        = "prometheus.mareo.fr"
    key_name      = "athena.mareo.fr."
    key_algorithm = "hmac-sha256"
    key_secret    = trimspace(file("../secrets/dns_key"))
  }
}

module "k8s-mareo-fr" {
  source = "./k8s.mareo.fr"
}

