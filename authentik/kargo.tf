resource "random_string" "kargo_client-id" {
  length  = 32
  special = false
}

resource "vault_generic_secret" "kargo_oidc-authentik" {
  path = "k8s/kargo/oidc-authentik"
  data_json = jsonencode({
    client_id = random_string.kargo_client-id.result
  })
}

resource "authentik_provider_oauth2" "kargo" {
  name                  = "kargo"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id             = random_string.kargo_client-id.result
  client_type           = "public"
  access_token_validity = "days=1"
  redirect_uris = [
    "https://kargo.mareo.fr/login",
    "http://localhost/login",
  ]
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-email.id,
  ]
  signing_key = data.authentik_certificate_key_pair.default.id

  lifecycle {
    ignore_changes = [
      client_secret,
    ]
  }
}

resource "authentik_application" "kargo" {
  name               = "Kargo"
  slug               = "kargo"
  group              = "Infrastructure"
  protocol_provider  = authentik_provider_oauth2.kargo.id
  meta_icon          = "https://docs.kargo.io/img/kargo.png"
  meta_launch_url    = "https://kargo.mareo.fr/"
  meta_publisher     = "Akuity Inc."
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "kargo_group-filtering" {
  for_each = { for idx, value in [
    "kargo",
    "kargo_admins",
  ] : idx => value }
  target = authentik_application.kargo.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
