resource "vault_generic_secret" "gitlab-runner_object-storage" {
  path         = "k8s/gitlab-runner/object-storage"
  disable_read = true
  data_json = jsonencode({
    s3_access_key = try(yamldecode(file("../secrets/rgw_user_gitlab.yml")).access_key, "FIXME")
    s3_secret_key = try(yamldecode(file("../secrets/rgw_user_gitlab.yml")).secret_key, "FIXME")
  })
}

resource "vault_generic_secret" "gitlab-runnet_token" {
  path         = "k8s/gitlab-runner/token"
  disable_read = true
  data_json = jsonencode({
    runner-registration-token = ""
    runner-token              = "FIXME"
  })
}
