resource "vault_generic_secret" "gatus_discord" {
  path         = "k8s/gatus/discord"
  disable_read = true
  data_json = jsonencode({
    webhook = "FIXME"
  })
}
