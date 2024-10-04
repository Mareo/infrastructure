resource "random_string" "hedgedoc_client-id" {
  length  = 32
  special = false
}

resource "random_password" "hedgedoc_client-secret" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "hedgedoc_authentik-openid" {
  path = "k8s/hedgedoc/authentik-openid"
  data_json = jsonencode({
    AUTHENTIK_OPENID_KEY    = random_string.hedgedoc_client-id.result
    AUTHENTIK_OPENID_SECRET = random_password.hedgedoc_client-secret.result
  })
}

resource "authentik_provider_oauth2" "hedgedoc" {
  name               = "hedgedoc"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id          = random_string.hedgedoc_client-id.result
  client_secret      = random_password.hedgedoc_client-secret.result
  redirect_uris = [
    "https://hedgedoc.mareo.fr/auth/oauth2/callback"
  ]
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-email.id,
  ]
  signing_key = data.authentik_certificate_key_pair.default.id
}

resource "authentik_application" "hedgedoc" {
  name               = "HedgeDoc"
  slug               = "hedgedoc"
  group              = "Services"
  protocol_provider  = authentik_provider_oauth2.hedgedoc.id
  meta_icon          = "https://github.com/hedgedoc/hedgedoc-logo/raw/main/LOGOTYPE/PNG/HedgeDoc-Logo%201.png"
  meta_launch_url    = "https://hedgedoc.mareo.fr/"
  meta_publisher     = "HedgeDoc Project"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "hedgedoc_group-filtering" {
  for_each = { for idx, value in [
    "hedgedoc",
  ] : idx => value }
  target = authentik_application.hedgedoc.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
