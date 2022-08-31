terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.8.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.2"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "3.2.3"
    }
  }
}
