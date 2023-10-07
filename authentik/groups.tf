locals {
  groups = {
    "alertmanager"               = {}
    "argocd"                     = {}
    "argocd_admins"              = {}
    "gatus"                      = {}
    "gitlab"                     = {}
    "gitlab_petitstream"         = { gitlab = { add_to_meta = true } }
    "gitlab_theseus"             = { gitlab = { add_to_meta = true } }
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
    "paperless"                  = {}
    "prometheus"                 = {}
    "proxmox"                    = {}
    "syncthing"                  = {}
    "vault"                      = {}
    "vault_admins"               = {}
    "vault_theseus"              = {}
    "vaultwarden"                = {}

    "petitstream_admins" = {}
    "petitstream_devs"   = {}
    "petitstream_ops"    = {}

    "theseus"         = {}
    "theseus_ops"     = {}
    "moodle"          = {}
    "moodle_admins"   = {}
    "moodle_managers" = {}
    "moodle_teachers" = {}
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
