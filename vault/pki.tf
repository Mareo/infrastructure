resource "vault_mount" "pki" {
  path = "pki"
  type = "pki"
}

locals {
  pki_url = "${local.vault_addr}/v1/${vault_mount.pki.path}"
}

resource "vault_pki_secret_backend_config_urls" "pki" {
  backend                 = vault_mount.pki.path
  issuing_certificates    = ["${local.pki_url}/ca"]
  crl_distribution_points = ["${local.pki_url}/crl"]
  ocsp_servers            = ["${local.pki_url}/ocsp"]
}

resource "vault_pki_secret_backend_crl_config" "pki" {
  backend      = vault_mount.pki.path
  expiry       = "72h"
  auto_rebuild = true
  enable_delta = true
}

resource "vault_pki_secret_backend_role" "roles" {
  for_each = {
    "cluster-local" = ["cluster.local"]
    "mareo-fr"      = ["mareo.fr"]
    "theseus-fr"    = ["theseus.fr", "theseusformation.fr"]
  }

  backend    = vault_mount.pki.path
  name       = each.key
  issuer_ref = vault_pki_secret_backend_issuer.pki-intermediate.issuer_ref

  ttl      = 90 * 24 * 60 * 60 # 90d
  key_type = "rsa"
  key_bits = 4096

  allowed_domains             = each.value
  allow_subdomains            = true
  allow_bare_domains          = true
  allow_ip_sans               = true
  allow_localhost             = true
  allow_wildcard_certificates = true
}
