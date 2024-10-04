resource "random_string" "argocd_client-id" {
  length  = 32
  special = false
}

resource "vault_generic_secret" "argocd_oidc-authentik" {
  path = "k8s/argocd/oidc-authentik"
  data_json = jsonencode({
    client_id = random_string.argocd_client-id.result
  })
}

resource "authentik_provider_oauth2" "argocd" {
  name                  = "argocd"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id             = random_string.argocd_client-id.result
  client_type           = "public"
  access_token_validity = "days=1"
  redirect_uris = [
    "https://argocd.mareo.fr/auth/callback",
    "http://localhost:8085/auth/callback",
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

resource "authentik_application" "argocd" {
  name               = "ArgoCD"
  slug               = "argocd"
  group              = "Infrastructure"
  protocol_provider  = authentik_provider_oauth2.argocd.id
  meta_icon          = "${local.icon-url}/argocd.png"
  meta_launch_url    = "https://argocd.mareo.fr/auth/login?return_url=https%3A%2F%2Fargocd.mareo.fr%2Fapplications"
  meta_publisher     = "Argo Project"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "argocd_group-filtering" {
  for_each = { for idx, value in [
    "argocd",
    "argocd_admins",

    "petitstream_devs",
    "petitstream_ops",

    "theseus_ops",
  ] : idx => value }
  target = authentik_application.argocd.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
