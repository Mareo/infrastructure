resource "authentik_flow" "passwordless-authentication-flow" {
  name               = "Welcome to authentik!"
  title              = "Welcome to authentik!"
  slug               = "passwordless-authentication-flow"
  designation        = "authentication"
  compatibility_mode = false
}

resource "authentik_stage_authenticator_validate" "webauthn-authentication" {
  name                  = "webauthn-authentication"
  device_classes        = ["webauthn"]
  not_configured_action = "deny"
}

resource "authentik_flow_stage_binding" "passwordless-authentication-flow_default-authentication-identification" {
  target = authentik_flow.passwordless-authentication-flow.uuid
  stage  = data.authentik_stage.default-authentication-identification.id
  order  = 10
}

resource "authentik_flow_stage_binding" "passwordless-authentication-flow_webauthn-authentication" {
  target = authentik_flow.passwordless-authentication-flow.uuid
  stage  = authentik_stage_authenticator_validate.webauthn-authentication.id
  order  = 20
}

resource "authentik_flow_stage_binding" "passwordless-authentication-flow_default-authentication-login" {
  target = authentik_flow.passwordless-authentication-flow.uuid
  stage  = data.authentik_stage.default-authentication-login.id
  order  = 30
}
