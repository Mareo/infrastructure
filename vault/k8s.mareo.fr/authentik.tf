resource "random_password" "authentik_secret-key" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "authentik_bootstrap-password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_generic_secret" "authentik" {
  path         = "k8s/authentik/app"
  disable_read = true
  data_json = jsonencode({
    secret_key         = random_password.authentik_secret-key.result
    bootstrap_password = random_password.authentik_bootstrap-password.result
  })
}

resource "random_password" "authentik_redis-password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_generic_secret" "authentik_redis-password" {
  path         = "k8s/authentik/redis"
  disable_read = true
  data_json = jsonencode({
    password = random_password.authentik_redis-password.result
  })
}
