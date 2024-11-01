resource "authentik_user" "gitlab_mail" {
  username = "gitlab-mail"
  name     = "gitlab-mail"
  type     = "service_account"
  path     = "services"
  groups   = [authentik_group.groups["mail"].id]
  attributes = jsonencode({
    "goauthentik.io/user/service-account" = true
    allowedEmails = [
      "@gitlab.mareo.fr",
    ]
    mailboxes = [
      "gitlab@gitlab.mareo.fr",
    ]
    mailAliases = [
      "@gitlab.mareo.fr",
    ]
    dovecotQuotaStorage  = "250M"
    dovecotQuotaMessages = 100
  })
}

resource "authentik_token" "gitlab_mail" {
  identifier   = "gitlab-mail"
  user         = authentik_user.gitlab_mail.id
  intent       = "app_password"
  expiring     = false
  retrieve_key = true
}

resource "vault_generic_secret" "gitlab_mail" {
  path = "k8s/gitlab/mail"
  data_json = jsonencode({
    username = authentik_user.gitlab_mail.username
    password = authentik_token.gitlab_mail.key
  })
}
