resource "authentik_flow" "apppassword-authentication-flow" {
  name        = "Welcome to authentik!"
  title       = "Welcome to authentik!"
  slug        = "apppassword-authentication-flow"
  designation = "authentication"
}

resource "authentik_stage_password" "authentication-apppassword" {
  name     = "AppPassword"
  backends = ["authentik.core.auth.TokenBackend"]
}

resource "authentik_stage_identification" "identification-authentication-apppassword" {
  name           = "identification-authentication-apppassword"
  user_fields    = ["username", "email"]
  sources        = [data.authentik_source.inbuilt.uuid]
  password_stage = authentik_stage_password.authentication-apppassword.id
}

resource "authentik_flow_stage_binding" "apppassword-authentication-flow_identification-authentication-apppassword" {
  target = authentik_flow.apppassword-authentication-flow.uuid
  stage  = authentik_stage_identification.identification-authentication-apppassword.id
  order  = 10
}

resource "authentik_flow_stage_binding" "apppassword-authentication-flow_default-authentication-login_1" {
  target = authentik_flow.apppassword-authentication-flow.uuid
  stage  = data.authentik_stage.default-authentication-login.id
  order  = 20
}
