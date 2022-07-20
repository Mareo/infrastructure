
resource "authentik_provider_ldap" "mail" {
  name         = "mail-ldap"
  base_dn      = "dc=mail,dc=mareo,dc=fr"
  bind_flow    = data.authentik_flow.default-authentication-flow.id
  search_group = authentik_group.groups["mail_service_accounts"].id
}

resource "authentik_application" "mail" {
  name              = "mail-ldap"
  slug              = "mail-ldap"
  protocol_provider = authentik_provider_ldap.mail.id
  group             = "Services"
  meta_icon         = "https://upload.wikimedia.org/wikipedia/commons/e/ec/Circle-icons-mail.svg"
}

resource "authentik_outpost" "mail-ldap" {
  name = "mail-ldap"
  type = "ldap"

  service_connection = authentik_service_connection_kubernetes.in-cluster.id
  protocol_providers = [
    authentik_provider_ldap.mail.id
  ]

  config = jsonencode({
    log_level              = "info"
    object_naming_template = "ak-outpost-%(name)s"

    authentik_host          = "https://auth.mareo.fr/"
    authentik_host_browser  = "https://auth.mareo.fr/"
    authentik_host_insecure = false

    kubernetes_replicas     = 1
    kubernetes_service_type = "ClusterIP"
  })
}

resource "authentik_user" "mail_dovecot" {
  username = "mail-dovecot"
  name     = "mail-dovecot"
  path     = "services"
  groups   = [authentik_group.groups["mail_service_accounts"].id]
  attributes = jsonencode({
    "goauthentik.io/user/service-account" = true
  })
}

resource "authentik_user" "mail_postfix" {
  username = "mail-postfix"
  name     = "mail-postfix"
  path     = "services"
  groups   = [authentik_group.groups["mail_service_accounts"].id]
  attributes = jsonencode({
    "goauthentik.io/user/service-account" = true
  })
}

resource "authentik_token" "mail_dovecot" {
  identifier   = "dovecot"
  user         = authentik_user.mail_dovecot.id
  intent       = "app_password"
  expiring     = false
  retrieve_key = true
}

resource "authentik_token" "mail_postfix" {
  identifier   = "postfix"
  user         = authentik_user.mail_postfix.id
  intent       = "app_password"
  expiring     = false
  retrieve_key = true
}

resource "vault_generic_secret" "mail_dovecot" {
  path         = "k8s/mail/dovecot"
  disable_read = true
  data_json = jsonencode({
    DOVECOT_LDAP_DN = format(
      "cn=%s,ou=users,%s",
      authentik_user.mail_dovecot.username,
      authentik_provider_ldap.mail.base_dn,
    )
    DOVECOT_LDAP_DNPASS = authentik_token.mail_dovecot.key
  })
}

resource "vault_generic_secret" "mail_postfix" {
  path         = "k8s/mail/postfix"
  disable_read = true
  data_json = jsonencode({
    LDAP_BIND_DN = format(
      "cn=%s,ou=users,%s",
      authentik_user.mail_postfix.username,
      authentik_provider_ldap.mail.base_dn,
    )
    LDAP_BIND_PW = authentik_token.mail_postfix.key
  })
}
