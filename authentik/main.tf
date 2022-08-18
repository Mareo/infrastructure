terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.8.2"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2022.8.1"
    }
  }

  backend "s3" {
    key = "authentik"
  }
}

provider "vault" {
  address = yamldecode(file("../config.yml")).vault_addr
}

provider "authentik" {
  url   = "https://auth.mareo.fr"
  token = trimspace(file("../secrets/authentik_token"))
}
