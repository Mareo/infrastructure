resource "tls_private_key" "nextcloud-saml" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "nextcloud-saml" {
  private_key_pem = tls_private_key.nextcloud-saml.private_key_pem

  subject {
    common_name  = "nextcloud.mareo.fr"
    organization = "mareo.fr"
  }

  validity_period_hours = 24 * 365 * 10 # 10y

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "authentik_certificate_key_pair" "nextcloud-saml" {
  name             = "nextcloud-saml"
  certificate_data = tls_self_signed_cert.nextcloud-saml.cert_pem
  key_data         = tls_private_key.nextcloud-saml.private_key_pem
}

resource "authentik_provider_saml" "nextcloud-saml" {
  name               = "nextcloud-saml"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  acs_url            = "https://nextcloud.mareo.fr/apps/user_saml/saml/acs"
  issuer             = "https://auth.mareo.fr"
  audience           = "https://nextcloud.mareo.fr/apps/user_saml/saml/metadata"
  sp_binding         = "post"
  signing_kp         = data.authentik_certificate_key_pair.default.id
  verification_kp    = authentik_certificate_key_pair.nextcloud-saml.id

  assertion_valid_not_before = "minutes=-3"

  name_id_mapping = data.authentik_property_mapping_saml.username.id
  property_mappings = [
    data.authentik_property_mapping_saml.upn.id,
    data.authentik_property_mapping_saml.name.id,
    data.authentik_property_mapping_saml.email.id,
    data.authentik_property_mapping_saml.username.id,
    data.authentik_property_mapping_saml.uid.id,
    authentik_property_mapping_saml.nextcloud-groups.id,
    authentik_property_mapping_saml.nextcloud-quota.id,
  ]
}

resource "authentik_application" "nextcloud-saml" {
  name               = "NextCloud (SAML)"
  slug               = "nextcloud-saml"
  group              = "Services"
  protocol_provider  = authentik_provider_saml.nextcloud-saml.id
  meta_icon          = "https://cdn.icon-icons.com/icons2/2699/PNG/512/nextcloud_logo_icon_168948.png"
  meta_launch_url    = "https://nextcloud.mareo.fr/"
  meta_publisher     = "NextCloud GmbHJ."
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "nextcloud-saml_group-filtering" {
  for_each = { for idx, value in [
    "nextcloud",
    "nextcloud_admins",
  ] : idx => value }
  target = authentik_application.nextcloud-saml.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}

resource "authentik_property_mapping_saml" "nextcloud-groups" {
  name       = "SAML NextCloud Groups"
  saml_name  = "http://schemas.xmlsoap.org/claims/Group"
  expression = <<-EOT
    for group in user.ak_groups.all():
      yield group.name
    if ak_is_group_member(request.user, name="nextcloud_admins"):
      yield "admin"
  EOT
}

resource "authentik_property_mapping_saml" "nextcloud-quota" {
  name       = "SAML NextCloud Quota"
  saml_name  = "nextcloud_quota"
  expression = <<-EOT
    return user.group_attributes().get("nextcloud_quota", "default")
  EOT
}
