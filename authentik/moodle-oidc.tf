resource "random_string" "moodle_client-id" {
  length  = 32
  special = false
}

resource "random_password" "moodle_client-secret" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "theseus-moodle_oidc-authentik" {
  path = "theseus/moodle/oidc-authentik"
  data_json = jsonencode({
    client_id     = random_string.moodle_client-id.result
    client_secret = random_password.moodle_client-secret.result
  })
}

resource "authentik_provider_oauth2" "moodle" {
  name               = "moodle"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id          = random_string.moodle_client-id.result
  client_secret      = random_password.moodle_client-secret.result
  redirect_uris = [
    "https://courses.theseusformation.fr/auth/oidc/",
    "https://courses.theseusformation.fr/admin/oauth2callback.php"
  ]
  property_mappings = [
    data.authentik_scope_mapping.scope-openid.id,
    data.authentik_scope_mapping.scope-profile.id,
    data.authentik_scope_mapping.scope-email.id,
    authentik_scope_mapping.moodle.id,
  ]
  signing_key = data.authentik_certificate_key_pair.default.id
}

resource "authentik_application" "moodle" {
  name               = "Moodle"
  slug               = "moodle"
  group              = "Theseus"
  protocol_provider  = authentik_provider_oauth2.moodle.id
  meta_icon          = "${local.icon-url}/moodle.png"
  meta_launch_url    = "https://courses.theseusformation.fr/"
  meta_publisher     = "Moodle HQ"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "moodle_group-filtering" {
  for_each = { for idx, value in [
    "moodle",
    "moodle_admins",
  ] : idx => value }
  target = authentik_application.moodle.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}

resource "authentik_scope_mapping" "moodle" {
  name       = "Moodle scope"
  scope_name = "moodle"
  expression = <<-EOT
    groups = [g.name for g in user.ak_groups.all()]
    return {
        "moodle_groups": ",".join(groups),
    }
  EOT
}
