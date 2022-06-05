locals {
  groups = [
    "argocd",
    "argocd_admins",
    "gitlab",
    "gitlab_admins",
    "nextcloud",
    "nextcloud_admins",
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
