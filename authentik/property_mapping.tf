data "authentik_property_mapping_saml" "upn" {
  managed = "goauthentik.io/providers/saml/upn"
}

data "authentik_property_mapping_saml" "name" {
  managed = "goauthentik.io/providers/saml/name"
}

data "authentik_property_mapping_saml" "email" {
  managed = "goauthentik.io/providers/saml/email"
}

data "authentik_property_mapping_saml" "username" {
  managed = "goauthentik.io/providers/saml/username"
}

data "authentik_property_mapping_saml" "uid" {
  managed = "goauthentik.io/providers/saml/uid"
}

data "authentik_property_mapping_saml" "groups" {
  managed = "goauthentik.io/providers/saml/groups"
}

data "authentik_property_mapping_saml" "ms-windowsaccountname" {
  managed = "goauthentik.io/providers/saml/ms-windowsaccountname"
}
