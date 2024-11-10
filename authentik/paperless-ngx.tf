resource "authentik_user" "paperless-ngx_mail" {
  username = "paperless-ngx-mail"
  name     = "paperless-ngx-mail"
  type     = "service_account"
  path     = "services"
  groups   = [authentik_group.groups["mail"].id]
  email    = "paperless-ngx@documents.mareo.fr"
  attributes = jsonencode({
    "goauthentik.io/user/service-account" = true
    allowedEmails = [
      "@documents.mareo.fr",
    ]
    mailboxRules = [
      "@documents.mareo.fr:paperless-ngx@documents.mareo.fr",
    ]
    mailboxes = [
      "paperless-ngx@documents.mareo.fr",
    ]
    dovecotQuotaStorage  = "5G"
    dovecotQuotaMessages = 1000
  })
}

resource "authentik_token" "paperless-ngx_mail" {
  identifier   = "paperless-ngx-mail"
  user         = authentik_user.paperless-ngx_mail.id
  intent       = "app_password"
  expiring     = false
  retrieve_key = true
}

resource "vault_generic_secret" "paperless-ngx_mail" {
  path = "k8s/paperless-ngx/mail"
  data_json = jsonencode({
    username = authentik_user.paperless-ngx_mail.username
    password = authentik_token.paperless-ngx_mail.key
  })
}

resource "authentik_provider_proxy" "paperless-ngx" {
  name                  = "paperless-ngx"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  access_token_validity = "days=1"
  mode                  = "forward_single"
  external_host         = "https://documents.mareo.fr/"
  invalidation_flow     = data.authentik_flow.default-provider-invalidation-flow.id
}

resource "authentik_application" "paperless-ngx" {
  name               = "Paperless-ngx"
  slug               = "paperless-ngx"
  group              = "Services"
  protocol_provider  = authentik_provider_proxy.paperless-ngx.id
  meta_icon          = "${local.icon-url}/paperless-ngx.png"
  meta_launch_url    = "https://documents.mareo.fr"
  meta_publisher     = "Daniel Quinn, Jonas Winkler, and the Paperless-ngx team"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "paperless-ngx_group-filtering" {
  for_each = { for idx, value in [
    "paperless",
  ] : idx => value }
  target = authentik_application.paperless-ngx.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
