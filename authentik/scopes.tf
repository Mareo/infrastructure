data "authentik_property_mapping_provider_scope" "scope-openid" {
  managed = "goauthentik.io/providers/oauth2/scope-openid"
}

data "authentik_property_mapping_provider_scope" "scope-profile" {
  managed = "goauthentik.io/providers/oauth2/scope-profile"
}

data "authentik_property_mapping_provider_scope" "scope-email" {
  managed = "goauthentik.io/providers/oauth2/scope-email"
}
