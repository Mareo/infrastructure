terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "3.4.1"
    }
  }
}
