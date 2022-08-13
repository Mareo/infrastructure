resource "vault_generic_secret" "petitstream_registry" {
  path         = "k8s/petitstream/registry"
  disable_read = true
  data_json = jsonencode({
    username = "FIXME"
    password = "FIXME"
  })
}

resource "vault_generic_secret" "petitstream_twitch" {
  path         = "k8s/petitstream/twitch"
  disable_read = true
  data_json = jsonencode({
    client_id     = "FIXME"
    client_secret = "FIXME"
  })
}

resource "vault_generic_secret" "petitstream_object-storage" {
  path         = "k8s/petitstream/object-storage"
  disable_read = true
  data_json = jsonencode({
    s3_access_key = try(yamldecode(file("../secrets/rgw_user_petitstream.yml")).access_key, "FIXME")
    s3_secret_key = try(yamldecode(file("../secrets/rgw_user_petitstream.yml")).secret_key, "FIXME")
  })
}

resource "random_password" "petitstream_redis-password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_generic_secret" "petitstream_redis-password" {
  path = "k8s/petitstream/redis"
  data_json = jsonencode({
    password = random_password.petitstream_redis-password.result
  })
}

resource "random_password" "petitstream-dev_redis-password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_generic_secret" "petitstream-dev_redis-password" {
  path = "k8s/petitstream-dev/redis"
  data_json = jsonencode({
    password = random_password.petitstream_redis-password.result
  })
}
