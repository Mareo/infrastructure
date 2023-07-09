data "authentik_flow" "default-authentication-flow" {
  slug = "default-authentication-flow"
}

data "authentik_source" "inbuilt" {
  managed = "goauthentik.io/sources/inbuilt"
}
