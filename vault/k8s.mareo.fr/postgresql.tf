resource "vault_generic_secret" "postgresql-secret" {
  path         = "k8s/postgresql"
  disable_read = true
  data_json = jsonencode({
    s3_access_key = try(yamldecode(file("../secrets/rgw_user_postgresql.yml")).access_key, "FIXME")
    s3_secret_key = try(yamldecode(file("../secrets/rgw_user_postgresql.yml")).secret_key, "FIXME")
  })
}
