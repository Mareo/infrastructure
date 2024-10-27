resource "random_password" "renovate-bot" {
  length  = 32
  special = true
}

resource "gitlab_user" "renovate-bot" {
  name             = "Renovate Bot"
  username         = "renovate-bot"
  password         = random_password.renovate-bot.result
  email            = "renovate-bot@gitlab.mareo.fr"
  is_admin         = false
  can_create_group = false
  is_external      = false
  reset_password   = false
}

resource "gitlab_personal_access_token" "renovate" {
  user_id = gitlab_user.renovate-bot.id
  name    = "Renovate personal access token"

  expires_at = "2050-01-01"

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

  wiki_enabled        = false
  packages_enabled    = false
  builds_access_level = "enabled"

  default_branch = "main"
  merge_method   = "ff"

  only_allow_merge_if_all_discussions_are_resolved = true
  remove_source_branch_after_merge                 = true
  shared_runners_enabled                           = true
  auto_cancel_pending_pipelines                    = "enabled"
  auto_devops_enabled                              = false
}

resource "gitlab_project_variable" "iac_renovate_token" {
  project   = gitlab_project.iac_renovate.id
  key       = "RENOVATE_TOKEN"
  value     = gitlab_personal_access_token.renovate.token
  protected = false
  masked    = true
}

resource "gitlab_pipeline_schedule" "iac_renovate" {
  project       = gitlab_project.iac_renovate.id
  description   = "Renovate"
  ref           = gitlab_project.iac_renovate.default_branch
  cron          = "0 * * * *"
  cron_timezone = "Europe/Paris"
}

resource "gitlab_pipeline_trigger" "iac_renovate" {
  project     = gitlab_project.iac_renovate.path_with_namespace
  description = "Renovate pipeline trigger"
}

resource "vault_generic_secret" "gitlab_renovate_pipeline-trigger" {
  path = "gitlab/renovate/pipeline-trigger"
  data_json = jsonencode({
    token = gitlab_pipeline_trigger.iac_renovate.token
  })
}

resource "gpg_private_key" "renovate" {
  name     = gitlab_user.renovate-bot.name
  email    = gitlab_user.renovate-bot.email
  rsa_bits = 4096
}

resource "gitlab_user_gpgkey" "renovate" {
  user_id = gitlab_user.renovate-bot.id
  key     = gpg_private_key.renovate.public_key
}

resource "gitlab_project_variable" "renovate_git-private-key" {
  project   = gitlab_project.iac_renovate.id
  key       = "RENOVATE_GIT_PRIVATE_KEY"
  value     = gpg_private_key.renovate.private_key
  protected = true
  raw       = true
}
