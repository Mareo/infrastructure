resource "authentik_provider_proxy" "syncthing" {
  name                  = "syncthing"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  access_token_validity = "days=15"
  mode                  = "forward_single"
  external_host         = "https://syncthing.mareo.fr/"
}

resource "authentik_application" "syncthing" {
  name               = "Syncthing"
  slug               = "syncthing"
  group              = "Services"
  protocol_provider  = authentik_provider_proxy.syncthing.id
  meta_icon          = "https://upload.wikimedia.org/wikipedia/commons/8/83/SyncthingAugustLogo.png"
  meta_launch_url    = "https://syncthing.mareo.fr/"
  meta_publisher     = "Jakob Borg et al."
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "syncthing_group-filtering" {
  for_each = { for idx, value in [
    "syncthing",
  ] : idx => value }
  target = authentik_application.syncthing.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
