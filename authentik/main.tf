terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.2.0"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2024.4.2"
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

locals {
  icon-url = "https://raw.githubusercontent.com/walkxcode/Dashboard-Icons/main/png"
}
