resource "random_password" "moodle_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_generic_secret" "moodle" {
  path = "theseus/moodle/admin-credentials"
  data_json = jsonencode({
    username = "admin"
    password = random_password.moodle_password.result
  })
}
