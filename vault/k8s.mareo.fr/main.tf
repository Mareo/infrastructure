terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.15.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "3.3.2"
    }
  }
}
