terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.15.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    discord = {
      source  = "Lucky3028/discord"
      version = "1.4.0"
    }
  }

  backend "s3" {
    key = "discord"
  }
}

provider "vault" {
  address = yamldecode(file("../config.yml")).vault_addr
}

data "vault_kv_secret_v2" "terraform" {
  mount = "discord"
  name  = "terraform"
}

provider "discord" {
  token = data.vault_kv_secret_v2.terraform.data["token"]
}

locals {
  server-id = "1098544224066080879"
}
