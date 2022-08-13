resource "authentik_provider_proxy" "petitstream-dev" {
  name               = "petitstream-dev"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  token_validity     = "days=1"
  mode               = "forward_single"
  external_host      = "https://dev.petitstream.com"
}

resource "authentik_application" "petitstream-dev" {
  name               = "Petitstream (dev)"
  slug               = "petitstream-dev"
  group              = "Petitstream"
  protocol_provider  = authentik_provider_proxy.petitstream-dev.id
  meta_icon          = "https://petitstream.com/favicon.ico"
  meta_launch_url    = "https://dev.petitstream.com/"
  meta_publisher     = "superjp"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "petitstream-dev_group-filtering" {
  for_each = { for idx, value in [
    "petitstream_devs",
    "petitstream_ops",
  ] : idx => value }
  target = authentik_application.petitstream-dev.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
