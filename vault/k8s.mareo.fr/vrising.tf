resource "random_password" "vrising_rcon-password" {
  length  = 16
  special = false
}

resource "vault_generic_secret" "vrising-server" {
  path         = "k8s/vrising/passwords"
  disable_read = true
  data_json = jsonencode({
    password      = "FIXME"
    rcon_password = random_password.vrising_rcon-password.result
  })
}
