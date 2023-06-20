resource "authentik_provider_proxy" "gatus" {
  name                  = "gatus"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  access_token_validity = "days=15"
  mode                  = "forward_single"
  external_host         = "https://gatus.mareo.fr/"
}

resource "authentik_application" "gatus" {
  name               = "Gatus"
  slug               = "gatus"
  group              = "Infrastructure"
  protocol_provider  = authentik_provider_proxy.gatus.id
  meta_icon          = "https://gatus.io/img/logo.svg"
  meta_launch_url    = "https://gatus.mareo.fr/"
  meta_publisher     = "TwiN"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "gatus_group-filtering" {
  for_each = { for idx, value in [
    "gatus",
  ] : idx => value }
  target = authentik_application.gatus.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
