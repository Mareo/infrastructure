resource "authentik_flow" "apppassword-authentication-flow" {
  name        = "Welcome to authentik!"
  title       = "Welcome to authentik!"
  slug        = "apppassword-authentication-flow"
  designation = "authentication"
}

data "authentik_stage" "default-authentication-identification" {
  name = "default-authentication-identification"
}

data "authentik_stage" "default-authentication-password" {
  name = "default-authentication-password"
}

data "authentik_stage" "default-authentication-mfa-validation" {
  name = "default-authentication-mfa-validation"
}

data "authentik_stage" "default-authentication-login" {
  name = "default-authentication-login"
}

resource "authentik_policy_expression" "user-has-authenticator" {
  name       = "user-has-authenticator"
  expression = "return ak_user_has_authenticator(request.user)"
}

resource "authentik_stage_password" "authentication-apppassword" {
  name     = "AppPassword"
  backends = ["authentik.core.auth.TokenBackend"]
}

resource "authentik_flow_stage_binding" "apppassword-authentication-flow_default-authentication-identification" {
  target = authentik_flow.apppassword-authentication-flow.uuid
  stage  = data.authentik_stage.default-authentication-identification.id
  order  = 10
}

resource "authentik_flow_stage_binding" "apppassword-authentication-flow_authentication-apppassword" {
  target               = authentik_flow.apppassword-authentication-flow.uuid
  stage                = authentik_stage_password.authentication-apppassword.id
  order                = 20
  evaluate_on_plan     = false
  re_evaluate_policies = true
}

resource "authentik_policy_binding" "user-has-authenticator_apppassword-authentication-flow_authentication-apppassword" {
  target = authentik_flow_stage_binding.apppassword-authentication-flow_authentication-apppassword.id
  policy = authentik_policy_expression.user-has-authenticator.id
  order  = 0
}

resource "authentik_flow_stage_binding" "apppassword-authentication-flow_default-authentication-login_1" {
  target               = authentik_flow.apppassword-authentication-flow.uuid
  stage                = data.authentik_stage.default-authentication-login.id
  order                = 30
  evaluate_on_plan     = false
  re_evaluate_policies = true
}

resource "authentik_policy_binding" "user-has-authenticator_apppassword-authentication-flow_default-authentication-login" {
  target = authentik_flow_stage_binding.apppassword-authentication-flow_default-authentication-login_1.id
  policy = authentik_policy_expression.user-has-authenticator.id
  order  = 0
}

resource "authentik_flow_stage_binding" "apppassword-authentication-flow_default-authentication-password" {
  target               = authentik_flow.apppassword-authentication-flow.uuid
  stage                = data.authentik_stage.default-authentication-password.id
  order                = 40
  evaluate_on_plan     = false
  re_evaluate_policies = true
}

resource "authentik_flow_stage_binding" "apppassword-authentication-flow_default-authentication-mfa-validation" {
  target               = authentik_flow.apppassword-authentication-flow.uuid
  stage                = data.authentik_stage.default-authentication-mfa-validation.id
  order                = 50
  evaluate_on_plan     = false
  re_evaluate_policies = true
}

resource "authentik_flow_stage_binding" "apppassword-authentication-flow_default-authentication-login_2" {
  target               = authentik_flow.apppassword-authentication-flow.uuid
  stage                = data.authentik_stage.default-authentication-login.id
  order                = 60
  evaluate_on_plan     = false
  re_evaluate_policies = true
}
