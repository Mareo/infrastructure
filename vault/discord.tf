resource "vault_mount" "discord" {
  path = "discord"
  type = "kv"
  options = {
    version = 2
  }
}

resource "vault_generic_secret" "ceph-csi_rbd-secret" {
  path         = "${vault_mount.discord.path}/terraform"
  disable_read = true
  data_json = jsonencode({
    token = "FIXME"
  })
}
