resource "random_string" "grafana_client-id" {
  length  = 32
  special = false
}

resource "random_password" "grafana_client-secret" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "grafana_oidc-authentik" {
  path = "k8s/kube-prometheus-stack/grafana/oidc-authentik"
  data_json = jsonencode({
    client_id     = random_string.grafana_client-id.result
    client_secret = random_password.grafana_client-secret.result
  })
}

resource "authentik_provider_oauth2" "grafana" {
  name               = "grafana"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id          = random_string.grafana_client-id.result
  client_secret      = random_password.grafana_client-secret.result
  redirect_uris = [
    "https://grafana.mareo.fr/login/generic_oauth"
  ]
  property_mappings = [
    data.authentik_scope_mapping.scope-openid.id,
    data.authentik_scope_mapping.scope-profile.id,
    data.authentik_scope_mapping.scope-email.id,
  ]
  signing_key = data.authentik_certificate_key_pair.default.id
}

resource "authentik_application" "grafana" {
  name               = "Grafana"
  slug               = "grafana"
  group              = "Infrastructure"
  protocol_provider  = authentik_provider_oauth2.grafana.id
  meta_icon          = "${local.icon-url}/grafana.png"
  meta_launch_url    = "https://grafana.mareo.fr"
  meta_publisher     = "Grafana Labs"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "grafana_group-filtering" {
  for_each = { for idx, value in [
    "grafana",
    "grafana_editors",
    "grafana_admins",
  ] : idx => value }
  target = authentik_application.grafana.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}

resource "authentik_user" "grafana_mail" {
  username = "grafana-mail"
  name     = "grafana-mail"
  path     = "services"
  groups   = [authentik_group.groups["mail"].id]
  attributes = jsonencode({
    "goauthentik.io/user/service-account" = true
    allowedEmails = [
      "@grafana.mareo.fr",
    ]
  })
}

resource "authentik_token" "grafana_mail" {
  identifier   = "grafana-mail"
  user         = authentik_user.grafana_mail.id
  intent       = "app_password"
  expiring     = false
  retrieve_key = true
}

resource "vault_generic_secret" "grafana_mail" {
  path = "k8s/kube-prometheus-stack/grafana/mail"
  data_json = jsonencode({
    username = authentik_user.grafana_mail.username
    password = authentik_token.grafana_mail.key
  })
}
