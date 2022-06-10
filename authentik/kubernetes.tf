resource "random_string" "kubernetes_client-id" {
  length  = 32
  special = false
}

resource "vault_generic_secret" "kubernetes_oidc-authentik" {
  path         = "k8s/k8s-auth/oidc-authentik"
  disable_read = true
  data_json = jsonencode({
    client_id     = random_string.kubernetes_client-id.result
  })
}

resource "authentik_provider_oauth2" "kubernetes" {
  name               = "kubernetes"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id          = random_string.kubernetes_client-id.result
  client_type        = "public"
  token_validity     = "days=1"
  redirect_uris = [
    "http://localhost:8000"
  ]
  sub_mode = "user_username"
  property_mappings = [
    data.authentik_scope_mapping.scope-openid.id,
    data.authentik_scope_mapping.scope-profile.id,
    data.authentik_scope_mapping.scope-email.id,
  ]
  signing_key = data.authentik_certificate_key_pair.default.id

  lifecycle {
    ignore_changes = [
      client_secret,
    ]
  }
}

resource "authentik_application" "kubernetes" {
  name               = "Kubernets"
  slug               = "kubernetes"
  group              = "Infrastructure"
  protocol_provider  = authentik_provider_oauth2.kubernetes.id
  meta_icon          = "https://cncf-branding.netlify.app/img/projects/kubernetes/icon/color/kubernetes-icon-color.svg/"
  meta_launch_url    = "blank://blank"
  meta_publisher     = "Cloud Native Computing Foundation"
  policy_engine_mode = "any"
}

resource "authentik_policy_binding" "kubernetes_group-filtering" {
  for_each = { for idx, value in [
    "kubernetes",
    "kubernetes_admins",
  ] : idx => value }
  target = authentik_application.kubernetes.uuid
  group  = authentik_group.groups[each.value].id
  order  = each.key
}
