resource "random_password" "foundry_admin-password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_generic_secret" "foundry_secret" {
  path         = "k8s/foundry/secret"
  disable_read = true
  data_json = jsonencode({
    username      = "FIXME"
    password      = "FIXME"
    licenseKey    = "FIXME"
    adminPassword = random_password.foundry_admin-password.result
  })
}

resource "vault_generic_secret" "foundry_s3" {
  path         = "k8s/foundry/s3"
  disable_read = true
  data_json = jsonencode({
    access_key = try(yamldecode(file("../secrets/rgw_user_foundry.yml")).access_key, "FIXME")
    secret_key = try(yamldecode(file("../secrets/rgw_user_foundry.yml")).secret_key, "FIXME")
  })
}
