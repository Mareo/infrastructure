resource "random_string" "vault_client-id" {
  length  = 32
  special = false
}

resource "random_password" "vault_client-secret" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "vault_oidc-authentik" {
  path         = "k8s/vault/oidc-authentik"
  disable_read = true
  data_json = jsonencode({
    client_id     = random_string.vault_client-id.result
    client_secret = random_password.vault_client-secret.result
  })
}

resource "vault_jwt_auth_backend" "authentik" {
  path               = "oidc"
  type               = "oidc"
  oidc_discovery_url = "https://auth.mareo.fr/application/o/vault/"
  oidc_client_id     = random_string.vault_client-id.result
  oidc_client_secret = random_password.vault_client-secret.result
  default_role       = "authentik"

  tune {
    listing_visibility = "unauth"
    default_lease_ttl  = "768h"
    max_lease_ttl      = "768h"
    token_type         = "default-service"
  }
}

resource "vault_jwt_auth_backend_role" "authentik" {
  backend        = vault_jwt_auth_backend.authentik.path
  role_name      = "authentik"
  token_policies = ["default"]

  oidc_scopes  = ["profile", "email"]
  groups_claim = "groups"
  user_claim   = "sub"
  role_type    = "oidc"

  allowed_redirect_uris = authentik_provider_oauth2.vault.redirect_uris
}

data "vault_identity_group" "admins" {
  group_name = "admins"
}

resource "vault_identity_group_alias" "vault_admins" {
  name           = "vault_admins"
  mount_accessor = vault_jwt_auth_backend.authentik.accessor
  canonical_id   = data.vault_identity_group.admins.id
}

resource "authentik_provider_oauth2" "vault" {
  name               = "vault"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id          = random_string.vault_client-id.result
  client_secret      = random_password.vault_client-secret.result
  redirect_uris = [
    "https://vault.mareo.fr/ui/vault/auth/oidc/oidc/callback",
    "https://vault.mareo.fr/oidc/callback",
    "http://localhost:8250/oidc/callback",
  ]
  sub_mode = "user_username"
  property_mappings = [
    data.authentik_scope_mapping.scope-openid.id,
    data.authentik_scope_mapping.scope-profile.id,
    data.authentik_scope_mapping.scope-email.id,
  ]
  signing_key = data.authentik_certificate_key_pair.default.id
}

resource "authentik_application" "vault" {
  name               = "HashiCorp Vault"
  slug               = "vault"
  group              = "Infrastructure"
  protocol_provider  = authentik_provider_oauth2.vault.id
  meta_icon          = "https://registry.terraform.io/images/providers/vault.svg"
  meta_launch_url    = "https://vault.mareo.fr/"
  meta_publisher     = "HashiCorp Inc."
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "vault_group-filtering" {
  for_each = { for idx, value in [
    "vault",
    "vault_admins",
  ] : idx => value }
  target = authentik_application.vault.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
