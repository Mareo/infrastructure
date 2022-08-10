resource "random_password" "hedgedoc_session-secret" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "hedgedoc_session-secret" {
  path = "k8s/hedgedoc/session-secret"
  data_json = jsonencode({
    SESSION_SECRET = random_password.hedgedoc_session-secret.result
  })
}

resource "vault_generic_secret" "hedgedoc_s3" {
  path         = "k8s/hedgedoc/object-storage"
  disable_read = true
  data_json = jsonencode({
    S3_ACCESS_KEY = try(yamldecode(file("../secrets/rgw_user_hedgedoc.yml")).access_key, "FIXME")
    S3_SECRET_KEY = try(yamldecode(file("../secrets/rgw_user_hedgedoc.yml")).secret_key, "FIXME")
  })
}

resource "vault_generic_secret" "hedgedoc_epita-openid" {
  path         = "k8s/hedgedoc/authentik-openid"
  disable_read = true
  data_json = jsonencode({
    AUTHENTIK_OPENID_KEY    = "FIXME"
    AUTHENTIK_OPENID_SECRET = "FIXME"
  })
}
