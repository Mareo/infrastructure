resource "vault_generic_secret" "headlamp_oidc-authentik" {
  path = "k8s/headlamp/oidc-authentik"
  data_json = jsonencode({
    OIDC_CLIENT_ID     = authentik_provider_oauth2.kubernetes.client_id
    OIDC_CLIENT_SECRET = authentik_provider_oauth2.kubernetes.client_secret
    OIDC_ISSUER_URL    = data.authentik_provider_oauth2_config.kubernetes.issuer_url
    OIDC_SCOPES        = "openid profile email"
  })
}

data "authentik_provider_oauth2_config" "kubernetes" {
  provider_id = authentik_provider_oauth2.kubernetes.id
}

resource "authentik_application" "headlamp" {
  name               = "Headlamp"
  slug               = "headlamp"
  group              = "Infrastructure"
  meta_icon          = "https://headlamp.dev/img/logo.svg"
  meta_launch_url    = "https://headlamp.mareo.fr/"
  meta_publisher     = "The Headlamp Contributors"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "headlamp_group-filtering" {
  for_each = { for idx, value in [
    "kubernetes",
    "kubernetes_admins",
  ] : idx => value }
  target = authentik_application.headlamp.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
