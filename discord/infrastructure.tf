resource "discord_category_channel" "infrastructure" {
  server_id = discord_server.server.id
  name      = "Infrastructure"
  position  = 1
}

resource "discord_text_channel" "argo-cd" {
  server_id                = discord_server.server.id
  name                     = "argo-cd"
  category                 = discord_category_channel.infrastructure.id
  sync_perms_with_category = true
  position                 = 2
}

resource "discord_text_channel" "gitlab-iac" {
  server_id                = discord_server.server.id
  name                     = "gitlab-iac"
  category                 = discord_category_channel.infrastructure.id
  sync_perms_with_category = true
  position                 = 3
}
