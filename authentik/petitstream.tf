resource "authentik_provider_proxy" "petitstream-admin" {
  name                  = "petitstream-admin"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  access_token_validity = "days=1"
  mode                  = "forward_single"
  external_host         = "https://petitstream.com/"
}

resource "authentik_application" "petitstream-admin" {
  name               = "Petitstream (admin)"
  slug               = "petitstream-admin"
  group              = "Petitstream"
  protocol_provider  = authentik_provider_proxy.petitstream-admin.id
  meta_icon          = "https://petitstream.com/favicon.ico"
  meta_launch_url    = "https://petitstream.com/admin/"
  meta_publisher     = "superjp"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "petitstream-admin_group-filtering" {
  for_each = { for idx, value in [
    "petitstream_admins",
  ] : idx => value }
  target = authentik_application.petitstream-admin.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}

resource "authentik_provider_proxy" "petitstream-dev" {
  name                  = "petitstream-dev"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  access_token_validity = "days=1"
  mode                  = "forward_single"
  external_host         = "https://dev.petitstream.com"
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
