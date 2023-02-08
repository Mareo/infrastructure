resource "authentik_user" "authentik_mail" {
  username = "authentik-mail"
  name     = "authentik-mail"
  path     = "services"
  groups   = [authentik_group.groups["mail"].id]
  attributes = jsonencode({
    "goauthentik.io/user/service-account" = true
    allowedEmails = [
      "@auth.mareo.fr",
    ]
  })
}

resource "authentik_token" "authentik_mail" {
  identifier   = "authentik-mail"
  user         = authentik_user.authentik_mail.id
  intent       = "app_password"
  expiring     = false
  retrieve_key = true
}

resource "vault_generic_secret" "authentik_mail" {
  path = "k8s/authentik/mail"
  data_json = jsonencode({
    username = authentik_user.authentik_mail.username
    password = authentik_token.authentik_mail.key
  })
}
