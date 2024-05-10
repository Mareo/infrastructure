resource "vault_pki_secret_backend_config_cluster" "pki" {
  backend  = vault_mount.pki.path
  path     = local.pki_url
  aia_path = local.pki_url
}

resource "vault_generic_endpoint" "pki_tune" {
  path                 = "sys/mounts/${vault_mount.pki.path}/tune"
  ignore_absent_fields = true
  disable_delete       = true
  data_json            = <<-EOT
    {
      "allowed_response_headers": [
          "Last-Modified",
          "Location",
          "Replay-Nonce",
          "Link"
        ],
      "passthrough_request_headers": [
        "If-Modified-Since"
      ]
    }
  EOT
}

resource "vault_generic_endpoint" "pki_acme" {
  path                 = "${vault_mount.pki.path}/config/acme"
  ignore_absent_fields = true
  disable_delete       = true

  data_json = jsonencode({
    enabled                  = true
    allow_role_ext_key_usage = true
    allowed_issuers          = [vault_pki_secret_backend_issuer.pki-intermediate.issuer_ref]
    allowed_roles            = keys(vault_pki_secret_backend_role.roles)
    default_directory_policy = "forbid"
    eab_policy               = "always-required"
  })
}
