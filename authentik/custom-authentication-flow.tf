resource "authentik_flow" "custom-authentication-flow" {
  name               = "Welcome to authentik!"
  title              = "Welcome to authentik!"
  slug               = "custom-authentication-flow"
  designation        = "authentication"
  compatibility_mode = true
}

resource "authentik_stage_identification" "passwordless-identification-authentication" {
  name              = "passwordless-identification-authentication"
  user_fields       = ["username", "email"]
  sources           = [data.authentik_source.inbuilt.uuid]
  password_stage    = data.authentik_stage.default-authentication-password.id
  passwordless_flow = authentik_flow.passwordless-authentication-flow.uuid
  recovery_flow     = authentik_flow.default-recovery-flow.uuid
}

resource "authentik_flow_stage_binding" "custom-authentication-flow_passwordless-identification" {
  target = authentik_flow.custom-authentication-flow.uuid
  stage  = authentik_stage_identification.passwordless-identification-authentication.id
  order  = 10
}

resource "authentik_flow_stage_binding" "custom-authentication-flow_default-authentication-mfa-validation" {
  target = authentik_flow.custom-authentication-flow.uuid
  stage  = data.authentik_stage.default-authentication-mfa-validation.id
  order  = 20
}

resource "authentik_flow_stage_binding" "custom-authentication-flow_default-authentication-login" {
  target = authentik_flow.custom-authentication-flow.uuid
  stage  = data.authentik_stage.default-authentication-login.id
  order  = 30
}
