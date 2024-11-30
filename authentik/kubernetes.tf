resource "authentik_provider_oauth2" "kubernetes" {
  name                  = "kubernetes"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id             = "kubernetes"
  client_type           = "public"
  access_token_validity = "days=1"
  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = "http://localhost:8000"
    },
    {
      matching_mode = "strict"
      url           = "https://headlamp.mareo.fr/oidc-callback"
    },
  ]
  sub_mode          = "user_username"
  invalidation_flow = data.authentik_flow.default-provider-invalidation-flow.id
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

resource "authentik_application" "kubernetes" {
  name               = "Kubernetes"
  slug               = "kubernetes"
  group              = "Infrastructure"
  protocol_provider  = authentik_provider_oauth2.kubernetes.id
  meta_icon          = "${local.icon-url}/kubernetes-dashboard.png"
  meta_launch_url    = "blank://blank"
  meta_publisher     = "Cloud Native Computing Foundation"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "kubernetes_group-filtering" {
  for_each = { for idx, value in [
    "kubernetes",
    "kubernetes_admins",
  ] : idx => value }
  target = authentik_application.kubernetes.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
