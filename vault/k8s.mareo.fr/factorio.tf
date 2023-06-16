resource "random_password" "factorio_rcon-password" {
  length  = 16
  special = false
}

resource "vault_generic_secret" "factorio-server" {
  path         = "k8s/factorio/server"
  disable_read = true
  data_json = jsonencode({
    password = "FIXME"
  })
}

resource "vault_generic_secret" "factorio-rcon" {
  path = "k8s/factorio/rcon"
  data_json = jsonencode({
    password = random_password.factorio_rcon-password.result
  })
}
