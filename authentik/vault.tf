resource "random_string" "vault_client-id" {
  length  = 32
  special = false
}

resource "random_password" "vault_client-secret" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "vault_oidc-authentik" {
  path = "k8s/vault/oidc-authentik"
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

  allowed_redirect_uris = [for aru in authentik_provider_oauth2.vault.allowed_redirect_uris : aru.url]
}

data "vault_identity_group" "admins" {
  group_name = "admins"
}

data "vault_identity_group" "theseus" {
  group_name = "theseus"
}

resource "vault_identity_group_alias" "vault_admins" {
  name           = "vault_admins"
  mount_accessor = vault_jwt_auth_backend.authentik.accessor
  canonical_id   = data.vault_identity_group.admins.id
}

resource "vault_identity_group_alias" "vault_theseus" {
  name           = "vault_theseus"
  mount_accessor = vault_jwt_auth_backend.authentik.accessor
  canonical_id   = data.vault_identity_group.theseus.id
}

resource "authentik_provider_oauth2" "vault" {
  name               = "vault"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id          = random_string.vault_client-id.result
  client_secret      = random_password.vault_client-secret.result
  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = "https://vault.mareo.fr/ui/vault/auth/oidc/oidc/callback"
    },
    {
      matching_mode = "strict"
      url           = "https://vault.mareo.fr/oidc/callback"
    },
    {
      matching_mode = "strict"
      url           = "http://localhost:8250/oidc/callback"
    },
  ]
  sub_mode          = "user_username"
  invalidation_flow = data.authentik_flow.default-provider-invalidation-flow.id
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-email.id,
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
