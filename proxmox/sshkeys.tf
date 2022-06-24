locals {
  sshkeys = yamldecode(file(local.sshkeys_path))["ssh_authorized_keys"]
}
