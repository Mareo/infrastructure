resource "random_password" "kube-prometheus-stack_grafana_admin-password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_generic_secret" "kube-prometheus-stack_grafana_admin-credentials" {
  path = "k8s/gitlab/initial-root-password"
  data_json = jsonencode({
    username = "admin"
    password = random_password.kube-prometheus-stack_grafana_admin-password.result
  })
}
