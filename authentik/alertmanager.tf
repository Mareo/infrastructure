resource "authentik_provider_proxy" "alertmanager" {
  name               = "alertmanager"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  token_validity     = "days=1"
  mode               = "forward_single"
  external_host      = "https://alertmanager.mareo.fr/"
}

resource "authentik_application" "alertmanager" {
  name               = "Alertmanager"
  slug               = "alertmanager"
  group              = "Infrastructure"
  protocol_provider  = authentik_provider_proxy.alertmanager.id
  meta_icon          = "https://devopy.io/wp-content/uploads/2019/02/bell_260.svg"
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
