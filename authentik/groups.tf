locals {
  groups = {
    "alertmanager"               = {}
    "argocd"                     = {}
    "argocd_admins"              = {}
    "argorollouts"               = {}
    "argowf"                     = {}
    "argowf_admins"              = {}
    "gatus"                      = {}
    "gitlab"                     = {}
    "gitlab_admins"              = {}
    "gitlab_auditors"            = {}
    "gitlab_externals"           = {}
    "gitlab_kubernetes"          = { gitlab = { add_to_meta = true } }
    "gitlab_petitstream"         = { gitlab = { add_to_meta = true } }
    "gitlab_service_accounts"    = {}
    "gitlab_theseus"             = { gitlab = { add_to_meta = true } }
    "grafana"                    = {}
    "grafana_editors"            = {}
    "grafana_admins"             = {}
    "hedgedoc"                   = {}
    "kargo"                      = {}
    "kargo_admins"               = {}
    "kubernetes"                 = {}
    "kubernetes_admins"          = {}
    "mail"                       = {}
    "mail_service_accounts"      = {}
    "nextcloud"                  = {}
    "nextcloud_admins"           = {}
    "nextcloud_service_accounts" = {}
    "paperless"                  = {}
    "proxmox"                    = {}
    "syncthing"                  = {}
    "vault"                      = {}
    "vault_admins"               = {}
    "vault_theseus"              = {}
    "vaultwarden"                = {}
    "victoria_metrics"           = {}

    "petitstream_admins" = {}
    "petitstream_devs"   = {}
    "petitstream_ops"    = {}

    "theseus"     = {}
    "theseus_ops" = {}
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
