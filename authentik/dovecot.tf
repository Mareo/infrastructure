
resource "authentik_provider_ldap" "dovecot" {
  name      = "dovecot-ldap"
  base_dn   = "dc=dovecot,dc=mareo,dc=fr"
  bind_flow = data.authentik_flow.default-authentication-flow.id
}

resource "authentik_application" "name" {
  name              = "dovecot-ldap"
  slug              = "dovecot-ldap"
  protocol_provider = authentik_provider_ldap.dovecot.id
}

resource "authentik_outpost" "dovecot-ldap" {
  name = "dovecot-ldap"
  type = "ldap"

  service_connection = authentik_service_connection_kubernetes.in-cluster.id
  protocol_providers = [
    authentik_provider_ldap.dovecot.id
  ]

  config = jsonencode({
    log_level                      = "info"
    object_naming_template         = "ak-outpost-%(name)s"

    authentik_host                 = "https://auth.mareo.fr/"
    authentik_host_browser         = "https://auth.mareo.fr/"
    authentik_host_insecure        = false

    kubernetes_replicas            = 1
    kubernetes_service_type        = "ClusterIP"
  })
}
