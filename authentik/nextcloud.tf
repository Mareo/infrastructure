resource "authentik_user" "nextcloud_mail" {
  username = "nextcloud-mail"
  name     = "nextcloud-mail"
  groups   = [authentik_group.groups["mail"].id]
  attributes = jsonencode({
    "goauthentik.io/user/service-account": true
  })
}

resource "authentik_token" "nextcloud_mail" {
  identifier   = "nextcloud-mail"
  user         = authentik_user.nextcloud_mail.id
  intent       = "app_password"
  expiring     = false
  retrieve_key = true
}

resource "vault_generic_secret" "nextcloud_mail" {
  path         = "k8s/nextcloud/mail"
  disable_read = true
  data_json = jsonencode({
    username = authentik_user.nextcloud_mail.username
    password = authentik_token.nextcloud_mail.key
  })
}
