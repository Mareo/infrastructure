resource "authentik_provider_proxy" "victoria-metrics" {
  name                  = "VictoriaMetrics"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  access_token_validity = "days=1"
  mode                  = "forward_single"
  external_host         = "https://victoria-metrics.mareo.fr/"
}

resource "authentik_application" "victoria-metrics" {
  name               = "VictoriaMetrics"
  slug               = "victoria-metrics"
  group              = "Infrastructure"
  protocol_provider  = authentik_provider_proxy.victoria-metrics.id
  meta_launch_url    = "https://victoria-metrics.mareo.fr"
  meta_publisher     = "VictoriaMetrics"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "victoria-metrics_group-filtering" {
  for_each = { for idx, value in [
    "victoria_metrics",
  ] : idx => value }
  target = authentik_application.victoria-metrics.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
