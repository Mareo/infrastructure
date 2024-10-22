resource "authentik_provider_proxy" "argo-rollouts" {
  name                  = "Argo Rollouts"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  access_token_validity = "days=15"
  mode                  = "forward_single"
  external_host         = "https://argo-rollouts.mareo.fr/"
}

resource "authentik_application" "argo-rollouts" {
  name               = "Argo Rollouts"
  slug               = "argo-rollouts"
  group              = "Infrastructure"
  protocol_provider  = authentik_provider_proxy.argo-rollouts.id
  meta_icon          = "${local.icon-url}/argocd.png"
  meta_launch_url    = "https://argo-rollouts.mareo.fr/"
  meta_publisher     = "Argo Project"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "argo-rollouts_group-filtering" {
  for_each = { for idx, value in [
    "argorollouts",
  ] : idx => value }
  target = authentik_application.argo-rollouts.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
