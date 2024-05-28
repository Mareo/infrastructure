resource "vault_generic_secret" "gatus_discord" {
  path         = "k8s/gatus/discord"
  disable_read = true
  data_json = jsonencode({
    DISCORD_WEBHOOK             = "FIXME"
    DISCORD_WEBHOOK_PETITSTREAM = "FIXME"
  })
}

resource "vault_generic_secret" "gatus_gitlab" {
  path         = "k8s/gatus/gitlab"
  disable_read = true
  data_json = jsonencode({
    GITLAB_WEBHOOK_URL       = "FIXME"
    GITLAB_AUTHORIZATION_KEY = "FIXME"
  })
}
