resource "random_password" "nextcloud_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_generic_secret" "nextcloud" {
  path         = "k8s/nextcloud"
  disable_read = true
  data_json = jsonencode({
    username = "admin"
    password = random_password.nextcloud_password.result
  })
}
