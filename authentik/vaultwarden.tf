resource "authentik_user" "vaultwarden_mail" {
  username = "vaultwarden-mail"
  name     = "vaultwarden-mail"
  groups   = [authentik_group.groups["mail"].id]
  attributes = jsonencode({
    "goauthentik.io/user/service-account": true
  })
}

resource "authentik_token" "vaultwarden_mail" {
  identifier   = "vaultwarden-mail"
  user         = authentik_user.vaultwarden_mail.id
  intent       = "app_password"
  expiring     = false
  retrieve_key = true
}

resource "vault_generic_secret" "vaultwarden_mail" {
  path         = "k8s/vaultwarden/mail"
  disable_read = true
  data_json = jsonencode({
    username = authentik_user.authentik_mail.username
    password = authentik_token.authentik_mail.key
  })
}
