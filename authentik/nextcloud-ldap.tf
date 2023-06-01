
resource "authentik_provider_ldap" "nextcloud-ldap" {
  name         = "nextcloud-ldap"
  base_dn      = "dc=nextcloud,dc=mareo,dc=fr"
  bind_flow    = data.authentik_flow.default-authentication-flow.id
  search_group = authentik_group.groups["nextcloud_service_accounts"].id
}

resource "authentik_outpost" "nextcloud-ldap" {
  name = "nextcloud-ldap"
  type = "ldap"

  service_connection = authentik_service_connection_kubernetes.in-cluster.id
  protocol_providers = [
    authentik_provider_ldap.nextcloud-ldap.id
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

resource "authentik_user" "nextcloud-ldap" {
  username = "nextcloud-ldap"
  name     = "nextcloud-ldap"
  path     = "services"
  groups   = [authentik_group.groups["nextcloud_service_accounts"].id]
  attributes = jsonencode({
    "goauthentik.io/user/service-account" : true
  })
}

resource "authentik_token" "nextcloud-ldap" {
  identifier   = "nextcloud-ldap"
  user         = authentik_user.nextcloud-ldap.id
  intent       = "app_password"
  expiring     = false
  retrieve_key = true
}

resource "vault_generic_secret" "nextcloud_ldap" {
  path = "k8s/nextcloud/ldap"
  data_json = jsonencode({
    bind_dn = format(
      "cn=%s,ou=users,%s",
      authentik_user.nextcloud-ldap.username,
      authentik_provider_ldap.nextcloud-ldap.base_dn,
    )
    bind_password = authentik_token.nextcloud-ldap.key
  })
}
