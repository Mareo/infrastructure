resource "random_string" "argo-workflows_client-id" {
  length  = 32
  special = false
}

resource "random_password" "argo-workflows_client-secret" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "argo-workflows_oidc-authentik" {
  path = "k8s/argo-workflows/oidc-authentik"
  data_json = jsonencode({
    client_id     = random_string.argo-workflows_client-id.result
    client_secret = random_password.argo-workflows_client-secret.result
  })
}

resource "authentik_provider_oauth2" "argo-workflows" {
  name                  = "argo-workflows"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id             = random_string.argo-workflows_client-id.result
  client_type           = "public"
  access_token_validity = "days=1"
  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = "https://workflows.mareo.fr/oauth2/callback"
    },
  ]
  invalidation_flow = data.authentik_flow.default-provider-invalidation-flow.id
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-email.id,
  ]
  signing_key = data.authentik_certificate_key_pair.default.id
}

resource "authentik_application" "argo-workflows" {
  name               = "Argo Workflows"
  slug               = "argo-workflows"
  group              = "Infrastructure"
  protocol_provider  = authentik_provider_oauth2.argo-workflows.id
  meta_icon          = "${local.icon-url}/argocd.png"
  meta_launch_url    = "https://argo-workflows.mareo.fr/auth/login?return_url=https%3A%2F%2Fargo-workflows.mareo.fr%2Fapplications"
  meta_publisher     = "Argo Project"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "argo-workflows_group-filtering" {
  for_each = { for idx, value in [
    "argowf",
    "argowf_admins",
  ] : idx => value }
  target = authentik_application.argo-workflows.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
