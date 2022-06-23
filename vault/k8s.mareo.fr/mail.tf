resource "random_password" "mail_postsrsd-secret" {
  length           = 18
  special          = false
}

resource "vault_generic_secret" "mail_postsrsd" {
  path         = "k8s/mail/postsrsd"
  disable_read = true
  data_json = jsonencode({
    secret = base64encode(random_password.mail_postsrsd-secret.result)
  })
}

resource "tls_private_key" "mail_opendkim-athena" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "vault_generic_secret" "mail_opendkim" {
  path         = "k8s/mail/opendkim"
  disable_read = true
  data_json = jsonencode({
    athena = tls_private_key.mail_opendkim-athena.private_key_pem
  })
}

resource "dns_txt_record_set" "mail_dkim-athena" {
  zone = "mareo.fr."
  name = "athena._domainkey"
  txt = [
    format(
      "v=DKIM1; k=rsa; p=%s",
      replace(
        replace(
          tls_private_key.mail_opendkim-athena.public_key_pem,
          "/--*.*--*/",
          ""
        ),
        "\n",
        "",
      )
    )
  ]
}
