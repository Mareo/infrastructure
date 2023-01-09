locals {
  groups = {
    "alertmanager"               = {}
    "argocd"                     = {}
    "argocd_admins"              = {}
    "gitlab"                     = {}
    "gitlab_petitstream"         = { gitlab = { add_to_meta = true } }
    "gitlab_externals"           = {}
    "gitlab_auditors"            = {}
    "gitlab_admins"              = {}
    "gitlab_service_accounts"    = {}
    "grafana"                    = {}
    "grafana_editors"            = {}
    "grafana_admins"             = {}
    "hedgedoc"                   = {}
    "kubernetes"                 = {}
    "kubernetes_admins"          = {}
    "mail"                       = {}
    "mail_service_accounts"      = {}
    "nextcloud"                  = {}
    "nextcloud_admins"           = {}
    "nextcloud_service_accounts" = {}
    "prometheus"                 = {}
    "proxmox"                    = {}
    "vault"                      = {}
    "vault_admins"               = {}
    "vaultwarden"                = {}

    "petitstream_admins" = {}
    "petitstream_devs"   = {}
    "petitstream_ops"    = {}
  }
}

data "authentik_group" "admins" {
  name = "authentik Admins"
}

resource "authentik_group" "groups" {
  for_each   = local.groups
  name       = each.key
  attributes = jsonencode(each.value)
}
