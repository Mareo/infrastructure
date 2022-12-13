terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.11.0"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2022.11.0"
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
