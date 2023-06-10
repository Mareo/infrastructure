resource "discord_text_channel" "system" {
  name                     = "system"
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  position                 = 0
}

resource "discord_server" "server" {
  name                          = "Mareo"
  verification_level            = 4 # VERY_HIGH
  explicit_content_filter       = 0 # DISABLED
  default_message_notifications = 0 # ALl_MESSAGES
  region                        = "eu-west"
  #icon_data_uri                 = ""
}

resource "discord_system_channel" "system" {
  server_id         = discord_server.server.id
  system_channel_id = discord_text_channel.system.id
}

resource "discord_invite" "invite" {
  channel_id = discord_text_channel.system.id
  max_age    = 7 * 24 * 60 * 60 # 1 week
  max_uses   = 1
}
