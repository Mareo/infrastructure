resource "random_password" "gitlab_initial-root-password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_generic_secret" "gitlab_initial-root-password" {
  path         = "k8s/gitlab/initial-root-password"
  disable_read = true
  data_json = jsonencode({
    password = random_password.gitlab_initial-root-password.result
  })
}
