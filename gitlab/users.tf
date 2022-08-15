resource "random_password" "mareo" {
  length  = 32
  special = true
}

resource "gitlab_user" "mareo" {
  username          = "mareo"
  name              = "Marin Hannache"
  email             = "mareo@mareo.fr"
  password          = random_password.mareo.result
  is_admin          = true
  can_create_group  = true
  skip_confirmation = true

  lifecycle {
    ignore_changes = [name, password]
  }
}

resource "gitlab_user_sshkey" "mareo" {
  user_id = gitlab_user.mareo.id
  title   = "cardno:11341889"
  key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVxiogrQvZfJs23ajIV9ooc8hWGJyumLHM0t+E4Hv4m"
}
