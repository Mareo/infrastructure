data "authentik_flow" "default-provider-authorization-implicit-consent" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default-provider-authorization-explicit-consent" {
  slug = "default-provider-authorization-explicit-consent"
}

resource "authentik_flow" "default-provider-authorization-one-time-consent" {
  name               = "Authorize Application"
  title              = "Redirecting to %(app)s"
  slug               = "default-provider-authorization-one-time-consent"
  designation        = "authorization"
  policy_engine_mode = "all"
  compatibility_mode = false
}

resource "authentik_stage_consent" "permanent-consent" {
  name = "default-provider-authorization-permanent-consent"
  mode = "permanent"
}

resource "authentik_flow_stage_binding" "default-provider-authorization-one-time-consent" {
  target = authentik_flow.default-provider-authorization-one-time-consent.uuid
  stage  = authentik_stage_consent.permanent-consent.id
  order  = 0
}
