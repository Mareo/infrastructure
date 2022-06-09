resource "authentik_provider_oauth2" "argocd-cli" {
  name               = "argocd-cli"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id          = "argocd-cli"
  client_type        = "public"
  token_validity     = "days=1"
  redirect_uris = [
    "http://localhost:8085/auth/callback",
  ]
  property_mappings = [
    data.authentik_scope_mapping.scope-openid.id,
    data.authentik_scope_mapping.scope-profile.id,
    data.authentik_scope_mapping.scope-email.id,
  ]
  signing_key = data.authentik_certificate_key_pair.default.id

  lifecycle {
    ignore_changes = [
      client_secret,
    ]
  }
}

resource "authentik_application" "argocd-cli" {
  name               = "ArgoCD (CLI)"
  slug               = "argocd-cli"
  group              = "Infrastructure"
  protocol_provider  = authentik_provider_oauth2.argocd-cli.id
  meta_icon          = "https://cncf-branding.netlify.app/img/projects/argo/icon/color/argo-icon-color.svg"
  meta_launch_url    = "blank://blank"
  meta_publisher     = "Argo Project"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "argocd-cli_group-filtering" {
  for_each = { for idx, value in [
    "argocd",
    "argocd_admins",
  ] : idx => value }
  target = authentik_application.argocd-cli.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
