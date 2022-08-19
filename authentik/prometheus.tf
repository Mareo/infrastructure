resource "authentik_provider_proxy" "prometheus" {
  name               = "prometheus"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  token_validity     = "days=1"
  mode               = "forward_single"
  external_host      = "https://prom.mareo.fr/"
}

resource "authentik_application" "prometheus" {
  name               = "prometheus"
  slug               = "prometheus"
  group              = "Infrastructure"
  protocol_provider  = authentik_provider_proxy.prometheus.id
  meta_icon          = "https://cncf-branding.netlify.app/img/projects/prometheus/icon/color/prometheus-icon-color.svg"
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
