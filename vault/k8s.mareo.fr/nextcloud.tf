resource "random_password" "nextcloud_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_generic_secret" "nextcloud" {
  path         = "k8s/nextcloud/initial-account-credentials"
  disable_read = true
  data_json = jsonencode({
    username = "admin"
    password = random_password.nextcloud_password.result
  })
}

resource "random_password" "nextcloud_redis-password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_generic_secret" "nextcloud_redis-password" {
  path         = "k8s/nextcloud/redis"
  disable_read = true
  data_json = jsonencode({
    password = random_password.nextcloud_redis-password.result
  })
}
