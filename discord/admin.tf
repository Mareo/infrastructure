resource "discord_role_everyone" "everyone" {
  server_id   = discord_server.server.id
  permissions = data.discord_permission.admin.allow_bits
}

data "discord_permission" "admin" {
  administrator = "allow"
}
