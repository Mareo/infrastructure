resource "random_password" "gitlab_initial-root-password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_generic_secret" "gitlab_initial-root-password" {
  path = "k8s/gitlab/initial-root-password"
  data_json = jsonencode({
    password = random_password.gitlab_initial-root-password.result
  })
}

resource "random_password" "gitlab_redis-password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_generic_secret" "gitlab_redis-password" {
  path = "k8s/gitlab/redis"
  data_json = jsonencode({
    password = random_password.gitlab_redis-password.result
  })
}

resource "vault_generic_secret" "gitlab_object-storage" {
  path         = "k8s/gitlab/object-storage"
  disable_read = true
  data_json = jsonencode({
    s3_access_key = try(yamldecode(file("../secrets/rgw_user_gitlab.yml")).access_key, "FIXME")
    s3_secret_key = try(yamldecode(file("../secrets/rgw_user_gitlab.yml")).secret_key, "FIXME")
  })
}
