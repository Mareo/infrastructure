locals {
  zones = {
    "mareo.fr." = [
      "athena",
      "auth",
      "gitlab",
      "grafana",
      "nextcloud",
      "vaultwarden",
    ]
    "hannache.fr." = []
  }
}

resource "random_password" "mail_postsrsd-secret" {
  length  = 18
  special = false
}

resource "vault_generic_secret" "mail_postsrsd" {
  path = "k8s/mail/postsrsd"
  data_json = jsonencode({
    secret = base64encode(random_password.mail_postsrsd-secret.result)
  })
}

resource "tls_private_key" "mail_opendkim-athena" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "vault_generic_secret" "mail_opendkim" {
  path = "k8s/mail/opendkim"
  data_json = jsonencode({
    athena = tls_private_key.mail_opendkim-athena.private_key_pem
  })
}

resource "dns_txt_record_set" "mail_dkim-root" {
  for_each = local.zones

  zone = each.key
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

resource "dns_txt_record_set" "mail_dkim-subdomains" {
  for_each = { for i, o in flatten([for zone, domains in local.zones :
    [for domain in domains : { zone = zone, domain = domain }]
  ]) : i => o }

  zone = each.value.zone
  name = "athena._domainkey.${each.value.domain}"
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
