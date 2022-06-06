terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.4.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.6.0"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2022.6.2"
    }
  }
}

provider "vault" {

}

provider "authentik" {
  url   = "https://auth.mareo.fr"
  token = trimspace(file("../secrets/authentik_token"))
}
