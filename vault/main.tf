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
  }

  backend "s3" {
    key = "vault"
  }
}

provider "vault" {
  address = yamldecode(file("../config.yml")).vault_addr
}

module "k8s-mareo-fr" {
  source = "./k8s.mareo.fr"
}
