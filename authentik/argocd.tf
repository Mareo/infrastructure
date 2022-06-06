resource "random_password" "argocd_client-id" {
  length  = 32
  special = false
}

resource "random_password" "argocd_client-secret" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "argocd_oidc-authentik" {
  path         = "k8s/argocd/oidc-authentik"
  disable_read = true
  data_json = jsonencode({
    client_id     = random_password.argocd_client-id.result
    client_secret = random_password.argocd_client-secret.result
  })
}

resource "authentik_provider_oauth2" "argocd" {
  name               = "argocd"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id          = random_password.argocd_client-id.result
  client_secret      = random_password.argocd_client-secret.result
  token_validity     = "days=1"
  redirect_uris = [
    "https://argocd.mareo.fr/auth/callback"
  ]
  property_mappings = [
    data.authentik_scope_mapping.scope-openid.id,
    data.authentik_scope_mapping.scope-profile.id,
    data.authentik_scope_mapping.scope-email.id,
  ]
  signing_key = data.authentik_certificate_key_pair.default.id
}

resource "authentik_application" "argocd" {
  name               = "ArgoCD"
  slug               = "argocd"
  group              = "Infrastructure"
  protocol_provider  = authentik_provider_oauth2.argocd.id
  meta_icon          = "https://cncf-branding.netlify.app/img/projects/argo/icon/color/argo-icon-color.svg"
  meta_launch_url    = "https://argocd.mareo.fr/auth/login"
  meta_publisher     = "Argo Project"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "argocd_group-filtering" {
  for_each = { for idx, value in [
    "argocd",
    "argocd_admins",
  ] : idx => value }
  target = authentik_application.argocd.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
