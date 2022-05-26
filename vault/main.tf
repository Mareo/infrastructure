terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
    }
  }
}

provider "vault" {

}

provider "kubernetes" {
  host           = "api.k8s.mareo.fr"
  config_path    = "../secrets/kubeconfig"
  config_context = "default"
}
