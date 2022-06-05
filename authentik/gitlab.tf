resource "random_password" "gitlab_client-id" {
  length  = 32
  special = false
}

resource "random_password" "gitlab_client-secret" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "gitlab_oidc-authentik" {
  path         = "k8s/gitlab/oidc-authentik"
  disable_read = true
  data_json = jsonencode({
    client_id     = random_password.gitlab_client-id.result
    client_secret = random_password.gitlab_client-secret.result
  })
}

resource "authentik_provider_oauth2" "gitlab" {
  name               = "gitlab"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id          = random_password.gitlab_client-id.result
  client_secret      = random_password.gitlab_client-secret.result
  redirect_uris = [
    "https://gitlab.mareo.fr/users/auth/openid_connect/callback"
  ]
}

resource "authentik_application" "gitlab" {
  name              = "GitLab"
  slug              = "gitlab"
  protocol_provider = authentik_provider_oauth2.gitlab.id
  meta_icon         = "https://about.gitlab.com/images/press/press-kit-icon.svg"
  meta_launch_url   = "https://gitlab.mareo.fr/"
  meta_publisher    = "GitLab Inc."
}
