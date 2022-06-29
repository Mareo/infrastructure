resource "authentik_stage_prompt_field" "recovery-password" {
  field_key   = "password"
  label       = "Password"
  type        = "password"
  required    = true
  placeholder = "Password"
  order       = 0
}

resource "authentik_stage_prompt_field" "recovery-password-repeat" {
  field_key   = "password_repeat"
  label       = "Password (repeat)"
  type        = "password"
  required    = true
  placeholder = "Password (repeat)"
  order       = 1
}

resource "authentik_flow" "default-recovery-flow" {
  name               = "Default recovery flow"
  title              = "Reset your password"
  slug               = "default-recovery-flow"
  designation        = "recovery"
  policy_engine_mode = "any"
  layout             = "stacked"
  background         = "/static/dist/assets/images/flow_background.jpg"
}

resource "authentik_stage_identification" "default-recovery-identification" {
  name                      = "default-recovery-identification"
  user_fields               = ["email", "username"]
  case_insensitive_matching = true
  sources                   = [data.authentik_source.inbuilt.uuid]
}

resource "authentik_stage_user_write" "default-recovery-user-write" {
  name = "default-recovery-user-write"
}

resource "authentik_stage_email" "default-recovery-email" {
  name                     = "default-recovery-email"
  use_global_settings      = true
  timeout                  = 30
  subject                  = "authentik"
  template                 = "email/password_reset.html"
  activate_user_on_success = true
}


resource "authentik_stage_prompt" "default-recovery-change-password" {
  name = "default-recovery-change-password"
  fields = [
    authentik_stage_prompt_field.recovery-password.id,
    authentik_stage_prompt_field.recovery-password-repeat.id,
  ]
}

resource "authentik_stage_user_login" "default-recovery-user-login" {
  name             = "default-recovery-user-login"
  session_duration = "seconds=0"
}

resource "authentik_flow_stage_binding" "default-recovery-identification" {
  target = authentik_flow.default-recovery-flow.uuid
  stage  = authentik_stage_identification.default-recovery-identification.id
  order  = 10
}

resource "authentik_flow_stage_binding" "default-recovery-email" {
  target = authentik_flow.default-recovery-flow.uuid
  stage  = authentik_stage_email.default-recovery-email.id
  order  = 20
}

resource "authentik_flow_stage_binding" "default-recovery-change-password" {
  target = authentik_flow.default-recovery-flow.uuid
  stage  = authentik_stage_prompt.default-recovery-change-password.id
  order  = 30
}

resource "authentik_flow_stage_binding" "default-recovery-user-write" {
  target = authentik_flow.default-recovery-flow.uuid
  stage  = authentik_stage_user_write.default-recovery-user-write.id
  order  = 40
}

resource "authentik_flow_stage_binding" "default-recovery-user-login" {
  target = authentik_flow.default-recovery-flow.uuid
  stage  = authentik_stage_user_login.default-recovery-user-login.id
  order  = 50
}
