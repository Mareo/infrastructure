resource "vault_generic_secret" "gitlab_saml-authentik" {
  path         = "k8s/gitlab/saml-authentik"
  disable_read = true
  data_json = jsonencode({
    idp_cert_fingerprint = data.authentik_certificate_key_pair.default.fingerprint256
  })
}

resource "authentik_provider_saml" "gitlab-saml" {
  name               = "gitlab-saml"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  acs_url            = "https://gitlab.mareo.fr/users/auth/saml/callback"
  issuer             = "https://gitlab.mareo.fr"
  audience           = "https://gitlab.mareo.fr"
  sp_binding         = "redirect"
  signing_kp         = data.authentik_certificate_key_pair.default.id

  property_mappings = [
    data.authentik_property_mapping_saml.upn.id,
    data.authentik_property_mapping_saml.name.id,
    data.authentik_property_mapping_saml.email.id,
    data.authentik_property_mapping_saml.username.id,
    data.authentik_property_mapping_saml.uid.id,
  ]
}

resource "authentik_application" "gitlab-saml" {
  name               = "GitLab (SAML)"
  slug               = "gitlab-saml"
  group              = "Services"
  protocol_provider  = authentik_provider_saml.gitlab-saml.id
  meta_icon          = "https://about.gitlab.com/images/press/press-kit-icon.svg"
  meta_launch_url    = "https://gitlab.mareo.fr/"
  meta_publisher     = "GitLab Inc."
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "gitlab-saml_group-filtering" {
  for_each = { for idx, value in [
    "gitlab",
    "gitlab_externals",
    "gitlab_admins",
  ] : idx => value }
  target = authentik_application.gitlab-saml.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
