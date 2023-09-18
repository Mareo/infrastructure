resource "authentik_user" "theseus-mail" {
  username = "theseus-mail"
  name     = "theseus-mail"
  type     = "service_account"
  path     = "services"
  groups   = [authentik_group.groups["mail"].id]
  email    = "courses@theseusformation.fr"
  attributes = jsonencode({
    "goauthentik.io/user/service-account" = true
    mailboxes = [
      "root@theseusformation.fr",
      "contact@theseusformation.fr",
    ]
    dovecotQuotaStorage  = "10G"
    dovecotQuotaMessages = 100000
  })
}
