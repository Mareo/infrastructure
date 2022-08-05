resource "vault_generic_secret" "petitstream_twitch" {
  path         = "k8s/petitstream/twitch"
  disable_read = true
  data_json = jsonencode({
    client_id     = "FIXME"
    client_secret = "FIXME"
  })
}

resource "vault_generic_secret" "petitstream_object" {
  path         = "k8s/petitstream/object-storage"
  disable_read = true
  data_json = jsonencode({
    s3_access_key = try(yamldecode(file("../secrets/rgw_user_petitstream.yml")).access_key, "FIXME")
    s3_secret_key = try(yamldecode(file("../secrets/rgw_user_petitstream.yml")).secret_key, "FIXME")
  })
}
