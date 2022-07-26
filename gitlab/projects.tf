resource "gitlab_project" "mareo-fr_infrastructure" {
  name             = "infrastructure"
  namespace_id     = gitlab_group.mareo-fr.id
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

resource "gitlab_service_pipelines_email" "email" {
  project                      = gitlab_project.mareo-fr_infrastructure.id
  recipients                   = ["gitlab@mareo.fr"]
  notify_only_broken_pipelines = true
  branches_to_be_notified      = "default_and_protected"
}

resource "gitlab_project_hook" "mareo-fr_infrastructure" {
  project                   = gitlab_project.mareo-fr_infrastructure.path_with_namespace
  url                       = "https://argocd.mareo.fr/api/webhook"
  token                     = data.vault_generic_secret.argocd_webhook-token.data["webhook.gitlab.secret"]
  push_events               = true
  tag_push_events           = true
  push_events_branch_filter = gitlab_project.mareo-fr_infrastructure.default_branch
  enable_ssl_verification   = true
}
