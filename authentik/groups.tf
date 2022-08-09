locals {
  groups = [
    "argocd",
    "argocd_petitstream",
    "argocd_petitstream_ops",
    "argocd_admins",
    "gitlab",
    "gitlab_externals",
    "gitlab_auditors",
    "gitlab_admins",
    "kubernetes",
    "kubernetes_admins",
    "mail",
    "mail_service_accounts",
    "nextcloud",
    "nextcloud_admins",
    "nextcloud_service_accounts",
    "vault",
    "vault_admins",
  ]
}

data "authentik_group" "admins" {
  name = "authentik Admins"
}

resource "authentik_group" "groups" {
  for_each = toset(local.groups)
  name     = each.key
}
