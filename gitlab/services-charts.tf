resource "gitlab_project" "services_charts_postfix" {
  name         = "postfix"
  path         = "postfix"
  namespace_id = gitlab_group.services_charts.id

  visibility_level    = "public"
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

resource "gitlab_project" "services_charts_dovecot" {
  name         = "dovecot"
  path         = "dovecot"
  namespace_id = gitlab_group.services_charts.id

  visibility_level    = "public"
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
