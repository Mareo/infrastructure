locals {
  _webhooks = flatten([
    for cat, chans in local.channels : [
      for c in chans : [
        for i, w in try(c.webhooks, []) :
        merge(
          w,
          {
            channel = discord_text_channel.text-channels["${cat}_${c.name}"]
            id      = "${cat}_${c.name}_${i}"
          },
        )
      ]
    ]
  ])
}

data "discord_local_image" "webhook-avatars" {
  for_each = toset([for w in local._webhooks : w.avatar_path if length(try(w.avatar_path, "")) > 0])

  file = each.value
}

resource "discord_webhook" "webhooks" {
  for_each = { for w in local._webhooks : w.id => w }

  channel_id      = each.value.channel.id
  name            = try(each.value.name, null)
  avatar_url      = try(each.value.avatar_url, null)
  avatar_data_uri = try(data.discord_local_image.webhook-avatars[each.value.avatar_path].data_uri, null)
}

resource "vault_generic_secret" "webhooks" {
  for_each = { for w in local._webhooks : w.vault_path => w... if length(try(w.vault_path, "")) > 0 }

  path = each.key
  data_json = jsonencode({
    for w in each.value : try(w.vault_key, "webhook") => discord_webhook.webhooks[w.id][try(w.url_attr, "url")]
  })
}
