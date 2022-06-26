resource "authentik_user" "authentik_mail" {
  username = "authentik-mail"
  name     = "authentik-mail"
  groups   = [authentik_group.groups["mail_service_accounts"].id]
  attributes = jsonencode({
    "goauthentik.io/user/service-account": true
  })
}

resource "authentik_token" "authentik_mail" {
  identifier   = "mail"
  user         = authentik_user.authentik_mail.id
  intent       = "app_password"
  expiring     = false
  retrieve_key = true
}

resource "vault_generic_secret" "authentik_mail" {
  path         = "k8s/authentik/mail"
  disable_read = true
  data_json = jsonencode({
    username = authentik_user.authentik_mail.username
    password = authentik_token.authentik_mail.key
  })
}
