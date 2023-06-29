resource "random_password" "kube-prometheus-stack_grafana_admin-password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_generic_secret" "kube-prometheus-stack_grafana_admin-credentials" {
  path = "k8s/kube-prometheus-stack/grafana/admin-credentials"
  data_json = jsonencode({
    username = "admin"
    password = random_password.kube-prometheus-stack_grafana_admin-password.result
  })
}

resource "vault_generic_secret" "kube-prometheus-stack_alertmanager_discord" {
  path         = "k8s/kube-prometheus-stack/alertmanager/discord"
  disable_read = true
  data_json = jsonencode({
    webhook = "FIXME"
  })
}

resource "vault_generic_secret" "kube-prometheus-stack_alertmanager_gitlab" {
  path         = "k8s/kube-prometheus-stack/alertmanager/gitlab"
  disable_read = true
  data_json = jsonencode({
    token = "FIXME"
  })
}
