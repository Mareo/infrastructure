resource "random_password" "paperless-ngx_admin-password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_generic_secret" "paperless-ngx_admin-credentials" {
  path = "k8s/paperless-ngx/admin-credentials"
  data_json = jsonencode({
    username = "admin"
    password = random_password.paperless-ngx_admin-password.result
  })
}

resource "random_password" "paperless-ngx_secret-key" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_generic_secret" "paperless-ngx_secret-key" {
  path = "k8s/paperless-ngx/secrets"
  data_json = jsonencode({
    PAPERLESS_SECRET_KEY = random_password.paperless-ngx_secret-key.result
  })
}

resource "random_password" "paperless-ngx_redis-password" {
  length  = 32
  special = false
}

resource "vault_generic_secret" "paperless-ngx_redis-password" {
  path = "k8s/paperless-ngx/redis"
  data_json = jsonencode({
    password = random_password.paperless-ngx_redis-password.result
  })
}
