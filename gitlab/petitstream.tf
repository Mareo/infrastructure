resource "gitlab_project" "iac_petitstream" {
  name             = "petitstream"
  namespace_id     = gitlab_group.iac.id
  visibility_level = "internal"

  wiki_enabled        = false
  packages_enabled    = false
  builds_access_level = "enabled"

  default_branch = "main"
  merge_method   = "ff"

  only_allow_merge_if_all_discussions_are_resolved = true
  shared_runners_enabled                           = true
  auto_cancel_pending_pipelines                    = "enabled"
  auto_devops_enabled                              = false
}

resource "gitlab_project_share_group" "petitstream" {
  project      = gitlab_project.iac_petitstream.id
  group_id     = gitlab_group.meta-children["petitstream"].id
  group_access = "developer"
}

resource "gitlab_project_hook" "petitstream_argocd" {
  project                   = gitlab_project.iac_petitstream.path_with_namespace
  url                       = "https://argocd.mareo.fr/api/webhook"
  token                     = data.vault_generic_secret.argocd_webhook-token.data["webhook.gitlab.secret"]
  push_events               = true
  tag_push_events           = true
  push_events_branch_filter = gitlab_project.iac_petitstream.default_branch
  enable_ssl_verification   = true
}

resource "gitlab_integration_slack" "iac_petitstream_slack" {
  project = gitlab_project.iac_petitstream.path_with_namespace
  webhook = data.vault_generic_secret.webhooks.data["gitlab-petitstream"]

  branches_to_be_notified      = "default_and_protected"
  notify_only_broken_pipelines = true

  confidential_issues_events = true
  issues_events              = true
  merge_requests_events      = true
  note_events                = true
  pipeline_events            = true
  push_events                = false
  tag_push_events            = true
}

resource "gitlab_deploy_token" "iac_petitstream_argocd" {
  project = gitlab_project.iac_petitstream.path_with_namespace
  name    = "ArgoCD deploy token"
  scopes  = ["read_repository"]
}

resource "vault_generic_secret" "argocd_repo_petitstream_argocd" {
  path = "k8s/argocd/repositories/iac-petitstream"
  data_json = jsonencode({
    username = gitlab_deploy_token.iac_petitstream_argocd.username
    password = gitlab_deploy_token.iac_petitstream_argocd.token
  })
}

data "vault_generic_secret" "k8s_petitstream_registry" {
  path = "k8s/petitstream/registry"
}

resource "gitlab_project_variable" "iac_renovate_petitstream_registry_username" {
  project   = gitlab_project.iac_renovate.id
  key       = "PETITSTREAM_REGISTRY_USERNAME"
  value     = data.vault_generic_secret.k8s_petitstream_registry.data["username"]
  protected = false
  masked    = true
}

resource "gitlab_project_variable" "iac_renovate_petitstream_registry_password" {
  project   = gitlab_project.iac_renovate.id
  key       = "PETITSTREAM_REGISTRY_PASSWORD"
  value     = data.vault_generic_secret.k8s_petitstream_registry.data["password"]
  protected = false
  masked    = false
}
