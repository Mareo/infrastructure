locals {
  zones = {
    "mareo.fr." = [
      "auth",
      "gitlab",
      "grafana",
      "nextcloud",
      "ouranos",
      "vaultwarden",
    ]
    "hannache.fr."         = []
    "theseusformation.fr." = []
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

resource "dns_txt_record_set" "spf" {
  for_each = { for o in flatten([for zone, domains in local.zones :
    concat(
      [for domain in domains : { zone = zone, name = domain, id = "${domain}.${zone}" }],
      [{ zone = zone, name = null, id = zone }]
    )
  ]) : o.id => o }

  zone = each.value.zone
  name = each.value.name
  txt  = ["v=spf1 mx a:ouranos.mareo.fr -all"]
}

resource "tls_private_key" "mail_opendkim-ouranos" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "vault_generic_secret" "mail_opendkim" {
  path = "k8s/mail/opendkim"
  data_json = jsonencode({
    ouranos = tls_private_key.mail_opendkim-ouranos.private_key_pem
  })
}

resource "dns_txt_record_set" "mail_dmarc" {
  for_each = toset(keys(local.zones))

  zone = each.key
  name = "_dmarc"
  txt  = ["v=DMARC1; p=reject; ruf=mailto:dmarc@mareo.fr; aspf=s; adkim=s; fo=1"]
}

resource "dns_txt_record_set" "mail_dkim-adsp" {
  for_each = { for o in flatten([for zone, domains in local.zones :
    concat(
      [for domain in domains : { zone = zone, suffix = ".${domain}" }],
      [{ zone = zone, suffix = "" }]
    )
  ]) : "${o.suffix}.${o.zone}" => o }

  zone = each.value.zone
  name = "_adsp._domainkey${each.value.suffix}"
  txt  = ["dkim=all"]
}

resource "dns_txt_record_set" "mail_dkim-key" {
  for_each = { for o in flatten([for zone, domains in local.zones :
    concat(
      [for domain in domains : { zone = zone, suffix = ".${domain}" }],
      [{ zone = zone, suffix = "" }]
    )
  ]) : "${o.suffix}.${o.zone}" => o }

  zone = each.value.zone
  name = "ouranos._domainkey${each.value.suffix}"
  txt = [
    format(
      "v=DKIM1; k=rsa; p=%s",
      replace(
        replace(
          tls_private_key.mail_opendkim-ouranos.public_key_pem,
          "/--*.*--*/",
          ""
        ),
        "\n",
        "",
      )
    )
  ]
}
