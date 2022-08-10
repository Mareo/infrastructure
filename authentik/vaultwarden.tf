resource "authentik_application" "vaultwarden" {
  name            = "Vaultwarden"
  slug            = "vaultwarden"
  group           = "Services"
  meta_icon       = "https://canada1.discourse-cdn.com/free1/uploads/vaultwarden/original/1X/14dfd7ce2a819b0da57fbe95ed906ce7723c86d2.png"
  meta_launch_url = "https://vaultwarden.mareo.fr/"
  meta_publisher  = "Daniel García"
}

resource "authentik_policy_binding" "vaultwarden_group-filtering" {
  for_each = { for idx, value in [
    "vaultwarden",
  ] : idx => value }
  target = authentik_application.vaultwarden.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}

resource "authentik_user" "vaultwarden_mail" {
  username = "vaultwarden-mail"
  name     = "vaultwarden-mail"
  path     = "services"
  groups   = [authentik_group.groups["mail"].id]
  attributes = jsonencode({
    "goauthentik.io/user/service-account" = true
    allowed_emails = [
      "vaultwarden.mareo.fr",
    ]
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
    username = authentik_user.vaultwarden_mail.username
    password = authentik_token.vaultwarden_mail.key
  })
}
