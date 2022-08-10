resource "random_password" "authentik_secret-key" {
  length           = 32
  special          = true
  override_special = "!%()-_=+[]{}:?"
}

resource "random_password" "authentik_bootstrap-password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "authentik_bootstrap-token" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "local_sensitive_file" "authentik_bootstrap-token" {
  content  = random_password.authentik_bootstrap-token.result
  filename = "${path.root}/../secrets/authentik_token"
}

resource "vault_generic_secret" "authentik" {
  path = "k8s/authentik/app"
  data_json = jsonencode({
    secret_key         = random_password.authentik_secret-key.result
    bootstrap_password = random_password.authentik_bootstrap-password.result
    bootstrap_token    = random_password.authentik_bootstrap-token.result
  })
}

resource "random_password" "authentik_redis-password" {
  length  = 32
  special = false
}

resource "vault_generic_secret" "authentik_redis-password" {
  path = "k8s/authentik/redis"
  data_json = jsonencode({
    password = random_password.authentik_redis-password.result
  })
}

resource "vault_generic_secret" "authentik_mail" {
  path         = "k8s/authentik/mail"
  disable_read = true
  data_json = jsonencode({
    username = "FIXME"
    password = "FIXME"
  })
}
