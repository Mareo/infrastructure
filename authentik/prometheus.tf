resource "authentik_provider_proxy" "prometheus" {
  name                  = "prometheus"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  access_token_validity = "days=1"
  mode                  = "forward_single"
  external_host         = "https://prometheus.mareo.fr/"
}

resource "authentik_application" "prometheus" {
  name               = "Prometheus"
  slug               = "prometheus"
  group              = "Infrastructure"
  protocol_provider  = authentik_provider_proxy.prometheus.id
  meta_icon          = "${local.icon-url}/prometheus.png"
  meta_launch_url    = "https://prometheus.mareo.fr"
  meta_publisher     = "Cloud Native Computing Foundation"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "prometheus_group-filtering" {
  for_each = { for idx, value in [
    "prometheus",
  ] : idx => value }
  target = authentik_application.prometheus.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
