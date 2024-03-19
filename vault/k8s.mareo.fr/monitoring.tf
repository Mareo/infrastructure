resource "random_password" "monitoring_grafana_admin-password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_generic_secret" "monitoring_grafana_admin-credentials" {
  path = "k8s/monitoring/grafana/admin-credentials"
  data_json = jsonencode({
    username = "admin"
    password = random_password.monitoring_grafana_admin-password.result
  })
}

resource "vault_generic_secret" "monitoring_alertmanager_discord" {
  path         = "k8s/monitoring/alertmanager/discord"
  disable_read = true
  data_json = jsonencode({
    webhook = "FIXME"
  })
}

resource "vault_generic_secret" "monitoring_alertmanager_gitlab" {
  path         = "k8s/monitoring/alertmanager/gitlab"
  disable_read = true
  data_json = jsonencode({
    token = "FIXME"
  })
}

resource "vault_generic_secret" "monitoring_loki_s3" {
  path         = "k8s/monitoring/loki/s3-creds"
  disable_read = true
  data_json = jsonencode({
    AWS_ACESS_KEY_ID      = try(yamldecode(file("../secrets/rgw_user_postgresql.yml")).access_key, "FIXME")
    AWS_SECRET_ACCESS_KEY = try(yamldecode(file("../secrets/rgw_user_postgresql.yml")).secret_key, "FIXME")
  })
}
