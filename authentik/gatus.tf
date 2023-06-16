resource "random_string" "gatus_client-id" {
  length  = 32
  special = false
}

resource "random_password" "gatus_client-secret" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "gatus_authentik-openid" {
  path = "k8s/gatus/authentik-openid"
  data_json = jsonencode({
    AUTHENTIK_OPENID_KEY    = random_string.gatus_client-id.result
    AUTHENTIK_OPENID_SECRET = random_password.gatus_client-secret.result
  })
}

resource "authentik_provider_oauth2" "gatus" {
  name               = "gatus"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id          = random_string.gatus_client-id.result
  client_secret      = random_password.gatus_client-secret.result
  redirect_uris = [
    "https://gatus.mareo.fr/authorization-code/callback"
  ]
  property_mappings = [
    data.authentik_scope_mapping.scope-openid.id,
    data.authentik_scope_mapping.scope-profile.id,
    data.authentik_scope_mapping.scope-email.id,
  ]
  signing_key           = data.authentik_certificate_key_pair.default.id
  access_token_validity = "days=1"
}

resource "authentik_application" "gatus" {
  name               = "Gatus"
  slug               = "gatus"
  group              = "Infrastructure"
  protocol_provider  = authentik_provider_oauth2.gatus.id
  meta_icon          = "https://gatus.io/img/logo.svg"
  meta_launch_url    = "https://gatus.mareo.fr/oidc/login"
  meta_publisher     = "TwiN"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "gatus_group-filtering" {
  for_each = { for idx, value in [
    "gatus",
  ] : idx => value }
  target = authentik_application.gatus.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
