resource "vault_pki_secret_backend_root_cert" "pki-root" {
  backend = vault_mount.pki.path
  type    = "internal"

  ttl                  = 10 * 365 * 24 * 60 * 60 # 10y
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true

  common_name  = "Mareo Root CA"
  issuer_name  = "mareo-root"
  organization = "Mareo"
  country      = "FR"

  permitted_dns_domains = [
    "cluster.local",
    "mareo.fr",
  ]
}

resource "vault_pki_secret_backend_intermediate_cert_request" "pki-intermediate" {
  backend = vault_mount.pki.path
  type    = "internal"

  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true

  common_name  = "Mareo Intermediate CA"
  organization = "Mareo"
  country      = "FR"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "pki-intermediate" {
  backend    = vault_mount.pki.path
  issuer_ref = vault_pki_secret_backend_root_cert.pki-root.issuer_id
  csr        = vault_pki_secret_backend_intermediate_cert_request.pki-intermediate.csr

  ttl            = format("%dh", 3 * 365 * 24) # 3y
  use_csr_values = true
  common_name    = vault_pki_secret_backend_intermediate_cert_request.pki-intermediate.common_name

  permitted_dns_domains = vault_pki_secret_backend_root_cert.pki-root.permitted_dns_domains
}

resource "vault_pki_secret_backend_intermediate_set_signed" "pki-intermediate" {
  backend     = vault_mount.pki.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.pki-intermediate.certificate_bundle
}

resource "vault_pki_secret_backend_issuer" "pki-intermediate" {
  backend     = vault_mount.pki.path
  issuer_ref  = vault_pki_secret_backend_intermediate_set_signed.pki-intermediate.imported_issuers[0]
  issuer_name = "mareo-intermediate"
}

resource "vault_pki_secret_backend_config_issuers" "pki" {
  backend                       = vault_mount.pki.path
  default                       = vault_pki_secret_backend_issuer.pki-intermediate.issuer_id
  default_follows_latest_issuer = false
}
