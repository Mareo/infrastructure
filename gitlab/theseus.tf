resource "gitlab_group" "theseus" {
  name             = "Theseus"
  path             = "theseus"
  visibility_level = "private"

  avatar      = "icons/theseus.png"
  avatar_hash = filesha256("icons/theseus.png")
}

resource "gitlab_group_membership" "theseus_renovate-bot" {
  group_id     = gitlab_group.theseus.id
  user_id      = gitlab_user.renovate-bot.id
  access_level = "maintainer"
}

resource "gitlab_group_share_group" "meta-theseus_theseus" {
  group_id       = gitlab_group.theseus.id
  share_group_id = gitlab_group.meta-children["theseus"].id
  group_access   = "owner"
}

resource "gitlab_group_membership" "theseus_mareo" {
  group_id     = gitlab_group.theseus.id
  user_id      = gitlab_user.users["mareo"].id
  access_level = "owner"
}

resource "gitlab_group_membership" "theseus_chewie" {
  group_id     = gitlab_group.theseus.id
  user_id      = gitlab_user.users["chewie"].id
  access_level = "owner"
}

resource "gitlab_project" "theseus_infrastructure" {
  name         = "infrastructure"
  namespace_id = gitlab_group.theseus.id

  visibility_level    = "private"
  builds_access_level = "private"

  wiki_enabled     = false
  packages_enabled = true

  default_branch = "main"
  merge_method   = "merge"

  only_allow_merge_if_all_discussions_are_resolved = true
  remove_source_branch_after_merge                 = true
  shared_runners_enabled                           = true
  auto_cancel_pending_pipelines                    = "enabled"
  auto_devops_enabled                              = false
}

resource "gitlab_project_hook" "theseus_infrastructure_argocd" {
  project                   = gitlab_project.theseus_infrastructure.path_with_namespace
  url                       = "https://argocd.mareo.fr/api/webhook"
  token                     = data.vault_generic_secret.argocd_webhook-token.data["webhook.gitlab.secret"]
  push_events               = true
  tag_push_events           = true
  push_events_branch_filter = gitlab_project.theseus_infrastructure.default_branch
  enable_ssl_verification   = true
}

resource "gitlab_deploy_token" "theseus_infrastructure_argocd" {
  project = gitlab_project.theseus_infrastructure.path_with_namespace
  name    = "ArgoCD deploy token"
  scopes  = ["read_repository"]
}

resource "vault_generic_secret" "argocd_repo_theseus-infrastructure" {
  path         = "k8s/argocd/repositories/theseus-infrastructure"
  disable_read = true
  data_json = jsonencode({
    username = gitlab_deploy_token.theseus_infrastructure_argocd.username
    password = gitlab_deploy_token.theseus_infrastructure_argocd.token
  })
}
