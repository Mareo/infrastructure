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
