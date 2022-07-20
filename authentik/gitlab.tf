resource "authentik_user" "gitlab_mail" {
  username = "gitlab-mail"
  name     = "gitlab-mail"
  path     = "services"
  groups   = [authentik_group.groups["mail"].id]
  attributes = jsonencode({
    "goauthentik.io/user/service-account" = true
    allowed_emails = [
      "gitlab.mareo.fr",
    ]
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
  path         = "k8s/gitlab/mail"
  disable_read = true
  data_json = jsonencode({
    username = authentik_user.gitlab_mail.username
    password = authentik_token.gitlab_mail.key
  })
}
