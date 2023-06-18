locals {
  _channels = [
    for i, c in flatten([
      for cat, chans in local.channels :
      concat(
        [{ "name" = cat, "type" = "category" }],
        [for c in chans : merge(c, { "category" = cat })],
      )
    ]) : merge(c, { "position" = i + 1 })
  ]
}

resource "discord_category_channel" "categories" {
  for_each = { for c in local._channels : c.name => c if c.type == "category" }

  server_id = discord_server.server.id
  name      = each.key
  position  = each.value.position
}

resource "discord_text_channel" "text-channels" {
  for_each = { for c in local._channels : "${c.category}_${c.name}" => c if c.type == "text" }

  server_id                = discord_server.server.id
  name                     = each.value.name
  category                 = discord_category_channel.categories[each.value.category].id
  sync_perms_with_category = true
  position                 = each.value.position
}

resource "discord_voice_channel" "voice-channels" {
  for_each = { for c in local._channels : "${c.category}_${c.name}" => c if c.type == "voice" }

  server_id                = discord_server.server.id
  name                     = each.value.name
  category                 = discord_category_channel.categories[each.value.category].id
  sync_perms_with_category = true
  position                 = each.value.position
}
