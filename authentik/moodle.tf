resource "authentik_user" "moodle_mail" {
  username = "moodle-mail"
  name     = "moodle-mail"
  type     = "service_account"
  path     = "services"
  groups   = [authentik_group.groups["mail"].id]
  attributes = jsonencode({
    "goauthentik.io/user/service-account" = true
    allowedEmails = [
      "@moodle.mareo.fr",
    ]
    mailboxes = [
      "moodle@moodle.mareo.fr",
    ]
    mailAliases = [
      "@moodle.mareo.fr",
    ]
    dovecotQuotaStorage  = "250M"
    dovecotQuotaMessages = 100
  })
}

resource "authentik_token" "moodle_mail" {
  identifier   = "moodle-mail"
  user         = authentik_user.moodle_mail.id
  intent       = "app_password"
  expiring     = false
  retrieve_key = true
}

resource "vault_generic_secret" "moodle_mail" {
  path = "theseus/moodle/mail"
  data_json = jsonencode({
    username = authentik_user.moodle_mail.username
    password = authentik_token.moodle_mail.key
  })
}
