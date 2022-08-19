locals {
  groups = [
    "alertmanager",
    "argocd",
    "argocd_admins",
    "gitlab",
    "gitlab_externals",
    "gitlab_auditors",
    "gitlab_admins",
    "grafana",
    "grafana_editors",
    "grafana_admins",
    "hedgedoc",
    "kubernetes",
    "kubernetes_admins",
    "mail",
    "mail_service_accounts",
    "nextcloud",
    "nextcloud_admins",
    "nextcloud_service_accounts",
    "prometheus",
    "vault",
    "vault_admins",
    "vaultwarden",

    "petitstream_admins",
    "petitstream_devs",
    "petitstream_ops",
  ]
}

data "authentik_group" "admins" {
  name = "authentik Admins"
}

resource "authentik_group" "groups" {
  for_each = toset(local.groups)
  name     = each.key
}
