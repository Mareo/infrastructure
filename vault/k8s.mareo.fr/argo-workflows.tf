resource "vault_generic_secret" "argo-workflows_object-storage" {
  path         = "k8s/argo-workflows/object-storage"
  disable_read = true
  data_json = jsonencode({
    s3_access_key = try(yamldecode(file("../secrets/rgw_user_argo-workflows.yml")).access_key, "FIXME")
    s3_secret_key = try(yamldecode(file("../secrets/rgw_user_argo-workflows.yml")).secret_key, "FIXME")
  })
}
