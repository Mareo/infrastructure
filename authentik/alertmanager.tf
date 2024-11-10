resource "authentik_provider_proxy" "alertmanager" {
  name                  = "alertmanager"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  access_token_validity = "days=1"
  mode                  = "forward_single"
  external_host         = "https://alertmanager.mareo.fr/"
  invalidation_flow     = data.authentik_flow.default-provider-invalidation-flow.id
}

resource "authentik_application" "alertmanager" {
  name               = "Alertmanager"
  slug               = "alertmanager"
  group              = "Infrastructure"
  protocol_provider  = authentik_provider_proxy.alertmanager.id
  meta_icon          = "${local.icon-url}/prometheus.png"
  meta_launch_url    = "https://alertmanager.mareo.fr"
  meta_publisher     = "Cloud Native Computing Foundation"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "alertmanager_group-filtering" {
  for_each = { for idx, value in [
    "alertmanager",
  ] : idx => value }
  target = authentik_application.alertmanager.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
