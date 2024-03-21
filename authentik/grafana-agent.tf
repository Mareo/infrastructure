resource "authentik_provider_proxy" "grafana-agent" {
  name                  = "Grafana Agent"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  access_token_validity = "days=1"
  mode                  = "forward_single"
  external_host         = "https://grafana-agent.mareo.fr/"
}

resource "authentik_application" "grafana-agent" {
  name               = "Grafana Agent"
  slug               = "grafana-agent"
  group              = "Infrastructure"
  protocol_provider  = authentik_provider_proxy.grafana-agent.id
  meta_icon          = "${local.icon-url}/grafana.png"
  meta_launch_url    = "https://grafana-agent.mareo.fr"
  meta_publisher     = "Grafana Labs"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "grafana-agent_group-filtering" {
  for_each = { for idx, value in [
    "grafana_admins",
  ] : idx => value }
  target = authentik_application.grafana-agent.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
