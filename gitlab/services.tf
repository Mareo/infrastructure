resource "gitlab_group" "services" {
  name             = "Services"
  path             = "services"
  visibility_level = "public"
}

resource "gitlab_group" "services_docker" {
  name             = "Docker"
  path             = "docker"
  parent_id        = gitlab_group.services.id
  visibility_level = "public"
}

resource "gitlab_group" "services_charts" {
  name             = "Helm Charts"
  path             = "charts"
  parent_id        = gitlab_group.services.id
  visibility_level = "public"
}

resource "gitlab_group_membership" "services_mareo" {
  group_id     = gitlab_group.services.id
  user_id      = gitlab_user.users["mareo"].id
  access_level = "owner"
}

resource "gitlab_group_membership" "services_renovate-bot" {
  group_id     = gitlab_group.services.id
  user_id      = gitlab_user.renovate-bot.id
  access_level = "maintainer"
}
