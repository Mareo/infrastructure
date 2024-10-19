resource "vault_mount" "pki" {
  path = "pki"
  type = "pki"

  allowed_response_headers = [
    "Last-Modified",
    "Location",
    "Replay-Nonce",
    "Link"
  ]
  passthrough_request_headers = ["If-Modified-Since"]

  max_lease_ttl_seconds = 10 * 365 * 24 * 60 * 60 # 10y
}

locals {
  pki_url = "${local.vault_addr}/v1/${vault_mount.pki.path}"
}

resource "vault_pki_secret_backend_config_cluster" "example" {
  backend  = vault_mount.pki.path
  path     = "${local.vault_addr}/v1/${vault_mount.pki.path}"
  aia_path = "${local.vault_addr}/v1/${vault_mount.pki.path}"
}

resource "vault_pki_secret_backend_config_urls" "pki" {
  backend                 = vault_mount.pki.path
  issuing_certificates    = ["{{cluster_aia_path}}/issuer/{{issuer_id}}/der"]
  crl_distribution_points = ["{{cluster_aia_path}}/issuer/{{issuer_id}}/crl/der"]
  ocsp_servers            = ["{{cluster_aia_path}}/ocsp"]
  enable_templating       = true

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
  }

  backend    = vault_mount.pki.path
  name       = each.key
  issuer_ref = vault_pki_secret_backend_issuer.pki-intermediate.issuer_ref

  ttl      = 90 * 24 * 60 * 60 # 90d
  max_ttl  = 90 * 24 * 60 * 60 # 90d
  key_type = "rsa"
  key_bits = 4096

  allowed_domains             = each.value
  allow_subdomains            = true
  allow_bare_domains          = true
  allow_ip_sans               = true
  allow_localhost             = true
  allow_wildcard_certificates = true
}
