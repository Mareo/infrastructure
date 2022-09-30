resource "random_string" "gitlab-oidc_client-id" {
  length  = 32
  special = false
}

resource "random_password" "gitlab-oidc_client-secret" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "gitlab_oidc-authentik" {
  path = "k8s/gitlab/oidc-authentik"
  data_json = jsonencode({
    client_id     = random_string.gitlab-oidc_client-id.result
    client_secret = random_password.gitlab-oidc_client-secret.result
  })
}

resource "authentik_provider_oauth2" "gitlab-oidc" {
  name               = "gitlab-oidc"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id          = random_string.gitlab-oidc_client-id.result
  client_secret      = random_password.gitlab-oidc_client-secret.result
  redirect_uris = [
    "https://gitlab.mareo.fr/users/auth/openid_connect/callback"
  ]
  property_mappings = [
    data.authentik_scope_mapping.scope-openid.id,
    data.authentik_scope_mapping.scope-profile.id,
    data.authentik_scope_mapping.scope-email.id,
  ]
  signing_key = data.authentik_certificate_key_pair.default.id
}

resource "authentik_application" "gitlab-oidc" {
  name               = "GitLab (OIDC)"
  slug               = "gitlab-oidc"
  group              = "Services"
  protocol_provider  = authentik_provider_oauth2.gitlab-oidc.id
  meta_icon          = "${local.icon-url}/gitlab.png"
  meta_launch_url    = "blank://blank"
  meta_publisher     = "GitLab Inc."
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "gitlab-oidc_group-filtering" {
  for_each = { for idx, value in [
    "gitlab",
    "gitlab_auditors",
    "gitlab_admins",
  ] : idx => value }
  target = authentik_application.gitlab-oidc.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
