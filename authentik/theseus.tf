resource "authentik_user" "theseus-mail" {
  username = "theseus-mail"
  name     = "theseus-mail"
  type     = "service_account"
  path     = "services"
  groups   = [authentik_group.groups["mail"].id]
  email    = "courses@theseusformation.fr"
  attributes = jsonencode({
    "goauthentik.io/user/service-account" = true
    mailboxRules = [
      "root@theseusformation.fr:root@theseus.fr",
      "contact@theseusformation.fr:contact@theseus.fr",
      "veille@theseusformation.fr:veille@theseus.fr",
    ]
    mailboxes = [
      "root@theseus.fr",
      "contact@theseus.fr",
      "veille@theseus.fr",
    ]
    dovecotQuotaStorage  = "10G"
    dovecotQuotaMessages = 100000
  })
}
