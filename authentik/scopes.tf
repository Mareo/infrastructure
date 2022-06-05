data "authentik_scope_mapping" "scope-openid" {
  managed = "goauthentik.io/providers/oauth2/scope-openid"
}

data "authentik_scope_mapping" "scope-profile" {
  managed = "goauthentik.io/providers/oauth2/scope-profile"
}

data "authentik_scope_mapping" "scope-email" {
  managed = "goauthentik.io/providers/oauth2/scope-email"
}
