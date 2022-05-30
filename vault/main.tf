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
  }
}

provider "vault" {

}

module "k8s-mareo-fr" {
  source = "./k8s.mareo.fr"
}
