data "discord_color" "admin" {
  hex = "#992d22"
}

data "discord_permission" "admin" {
  administrator = "allow"
}

resource "discord_role" "admin" {
  name        = "admin"
  server_id   = discord_server.server.id
  permissions = data.discord_permission.admin.allow_bits
  position    = 1
  color       = data.discord_color.admin.dec
  hoist       = true
  mentionable = true
}

resource "discord_member_roles" "admins" {
  for_each = toset(local.admins)

  server_id = discord_server.server.id
  user_id   = each.key

  role {
    role_id  = discord_role.admin.id
    has_role = true
  }
}

resource "discord_role_everyone" "everyone" {
  server_id   = discord_server.server.id
  permissions = data.discord_permission.default.allow_bits
}

data "discord_permission" "default" {
  view_channel         = "allow"
  read_message_history = "allow"
}
