resource "random_password" "vaultwarden_admin-token" {
  length  = 48
  special = false
}

resource "vault_generic_secret" "vaultwarden_admin" {
  path = "k8s/vaultwarden/admin"
  data_json = jsonencode({
    token = base64encode(random_password.vaultwarden_admin-token.result)
  })
}
