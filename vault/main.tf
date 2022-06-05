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
  }
}

module "k8s-mareo-fr" {
  source = "./k8s.mareo.fr"
}
