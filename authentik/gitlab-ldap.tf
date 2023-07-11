resource "authentik_provider_ldap" "gitlab-ldap" {
  name         = "gitlab-ldap"
  base_dn      = "dc=gitlab,dc=mareo,dc=fr"
  bind_flow    = data.authentik_flow.default-authentication-flow.id
  search_group = authentik_group.groups["gitlab_service_accounts"].id
  mfa_support  = false
}

resource "authentik_application" "gitlab-ldap" {
  name               = "GitLab (LDAP)"
  slug               = "gitlab-ldap"
  protocol_provider  = authentik_provider_ldap.gitlab-ldap.id
  group              = "Services"
  meta_icon          = "${local.icon-url}/gitlab.png"
  meta_launch_url    = "blank://blank"
  meta_publisher     = "GitLab Inc."
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "gitlab-ldap_group-filtering" {
  for_each = { for idx, value in [
    "gitlab",
    "gitlab_auditors",
    "gitlab_admins",
    "gitlab_service_accounts",
  ] : idx => value }
  target = authentik_application.gitlab-ldap.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}

resource "authentik_outpost" "gitlab-ldap" {
  name = "gitlab-ldap"
  type = "ldap"

  service_connection = authentik_service_connection_kubernetes.in-cluster.id
  protocol_providers = [
    authentik_provider_ldap.gitlab-ldap.id
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

resource "authentik_user" "gitlab-ldap" {
  username = "gitlab-ldap"
  name     = "gitlab-ldap"
  path     = "services"
  groups   = [authentik_group.groups["gitlab_service_accounts"].id]
  attributes = jsonencode({
    "goauthentik.io/user/service-account" = true
  })
}

resource "authentik_token" "gitlab_ldap" {
  identifier   = "gitlab-ldap"
  user         = authentik_user.gitlab-ldap.id
  intent       = "app_password"
  expiring     = false
  retrieve_key = true
}

resource "vault_generic_secret" "gitlab_ldap" {
  path = "k8s/gitlab/ldap"
  data_json = jsonencode({
    bind_dn = format(
      "cn=%s,ou=users,%s",
      authentik_user.gitlab-ldap.username,
      authentik_provider_ldap.gitlab-ldap.base_dn,
    )
    bind_password = authentik_token.gitlab_ldap.key
  })
}
