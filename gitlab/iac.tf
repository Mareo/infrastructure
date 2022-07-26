resource "gitlab_group" "iac" {
  name             = "Infrastructure as Code"
  path             = "iac"
  visibility_level = "public"
}

resource "gitlab_project" "iac_infrastructure" {
  name             = "infrastructure"
  namespace_id     = gitlab_group.iac.id
  visibility_level = "private"

  import_url = "git://mareo.fr/infrastructure"

  wiki_enabled      = false
  packages_enabled  = true
  pipelines_enabled = true

  default_branch = "main"

  only_allow_merge_if_all_discussions_are_resolved = true
  auto_cancel_pending_pipelines                    = "enabled"
  auto_devops_enabled                              = false
}

resource "gitlab_project_hook" "iac_infrastructure" {
  project                   = gitlab_project.iac_infrastructure.path_with_namespace
  url                       = "https://argocd.mareo.fr/api/webhook"
  token                     = data.vault_generic_secret.argocd_webhook-token.data["webhook.gitlab.secret"]
  push_events               = true
  tag_push_events           = true
  push_events_branch_filter = gitlab_project.iac_infrastructure.default_branch
  enable_ssl_verification   = true
}

resource "gitlab_deploy_token" "iac_infrastructure_argocd" {
  project = gitlab_project.iac_infrastructure.path_with_namespace
  name    = "ArgoCD deploy token"
  scopes  = ["read_repository"]
}

resource "vault_generic_secret" "argocd_repo_iac-infrastructure" {
  path = "k8s/argocd/repositories/iac-infrastructure"
  disable_read = true
  data_json = jsonencode({
    username = gitlab_deploy_token.iac_infrastructure_argocd.username
    password = gitlab_deploy_token.iac_infrastructure_argocd.token
  })
}
