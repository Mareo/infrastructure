resource "random_string" "proxmox_client-id" {
  length  = 32
  special = false
}

resource "random_password" "proxmox_client-secret" {
  length  = 64
  special = false
}

resource "authentik_provider_oauth2" "proxmox" {
  name               = "proxmox"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id          = random_string.proxmox_client-id.result
  client_secret      = random_password.proxmox_client-secret.result
  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = "https://ouranos.mareo.fr:8006"
    },
  ]
  invalidation_flow = data.authentik_flow.default-provider-invalidation-flow.id
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-email.id,
  ]
  signing_key = data.authentik_certificate_key_pair.default.id
}

resource "authentik_application" "proxmox" {
  name               = "Proxmox"
  slug               = "proxmox"
  group              = "Infrastructure"
  protocol_provider  = authentik_provider_oauth2.proxmox.id
  meta_icon          = "${local.icon-url}/proxmox.png"
  meta_launch_url    = "https://ouranos.mareo.fr:8006"
  meta_publisher     = "Proxmox Server Solutions GmbH"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "proxmox_group-filtering" {
  for_each = { for idx, value in [
    "proxmox",
  ] : idx => value }
  target = authentik_application.proxmox.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
