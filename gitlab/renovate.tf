resource "random_password" "renovate-bot" {
  length  = 32
  special = true
}

resource "gitlab_user" "renovate-bot" {
  name             = "Renovate bot"
  username         = "renovate-bot"
  password         = random_password.renovate-bot.result
  email            = "renovate@gitlab.mareo.fr"
  is_admin         = false
  can_create_group = false
  is_external      = false
  reset_password   = false
}

resource "gitlab_personal_access_token" "renovate" {
  user_id    = gitlab_user.renovate-bot.id
  name       = "Renovate personal access token"

  scopes = [
    "read_user",
    "api",
    "write_repository",
  ]
}

resource "gitlab_project" "iac_renovate" {
  name             = "renovate"
  namespace_id     = gitlab_group.iac.id
  visibility_level = "internal"

  wiki_enabled      = false
  packages_enabled  = false
  pipelines_enabled = true

  default_branch = "main"
  merge_method   = "ff"

  only_allow_merge_if_all_discussions_are_resolved = true
  auto_cancel_pending_pipelines                    = "enabled"
  auto_devops_enabled                              = false
}

resource "gitlab_project_variable" "iac_renovate_token" {
  project   = gitlab_project.iac_renovate.id
  key       = "RENOVATE_TOKEN"
  value     = gitlab_personal_access_token.renovate.token
  protected = true
  masked    = true
}
