resource "authentik_stage_prompt_field" "recovery-password" {
  name        = "password_recovery-change-password"
  field_key   = "password"
  label       = "Password"
  type        = "password"
  required    = true
  placeholder = "Password"
  order       = 0
}

resource "authentik_stage_prompt_field" "recovery-password-repeat" {
  name        = "password_repeat_recovery-change-password"
  field_key   = "password_repeat"
  label       = "Password (repeat)"
  type        = "password"
  required    = true
  placeholder = "Password (repeat)"
  order       = 1
}

resource "authentik_flow" "recovery-flow" {
  name               = "Default recovery flow"
  title              = "Reset your password"
  slug               = "recovery-flow"
  designation        = "recovery"
  policy_engine_mode = "any"
  layout             = "stacked"
  background         = "/static/dist/assets/images/flow_background.jpg"
}

resource "authentik_stage_email" "recovery-email" {
  name                     = "recovery-email"
  use_global_settings      = true
  timeout                  = 30
  subject                  = "authentik"
  template                 = "email/password_reset.html"
  activate_user_on_success = true
}

resource "authentik_stage_prompt" "recovery-change-password" {
  name = "recovery-change-password"
  fields = [
    authentik_stage_prompt_field.recovery-password.id,
    authentik_stage_prompt_field.recovery-password-repeat.id,
  ]
}

resource "authentik_flow_stage_binding" "recovery-identification" {
  target = authentik_flow.recovery-flow.uuid
  stage  = data.authentik_stage.default-authentication-identification.id
  order  = 10
}

resource "authentik_flow_stage_binding" "recovery-authentication-mfa-validation" {
  target = authentik_flow.recovery-flow.uuid
  stage  = data.authentik_stage.default-authentication-mfa-validation.id
  order  = 20
}

resource "authentik_flow_stage_binding" "recovery-email" {
  target = authentik_flow.recovery-flow.uuid
  stage  = authentik_stage_email.recovery-email.id
  order  = 30
}

resource "authentik_flow_stage_binding" "recovery-change-password" {
  target = authentik_flow.recovery-flow.uuid
  stage  = authentik_stage_prompt.recovery-change-password.id
  order  = 40
}

resource "authentik_flow_stage_binding" "recovery-user-write" {
  target = authentik_flow.recovery-flow.uuid
  stage  = data.authentik_stage.default-user-settings-write.id
  order  = 50
}

resource "authentik_flow_stage_binding" "recovery-user-login" {
  target = authentik_flow.recovery-flow.uuid
  stage  = data.authentik_stage.default-authentication-login.id
  order  = 60
}
