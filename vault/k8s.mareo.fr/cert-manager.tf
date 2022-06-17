resource "vault_generic_secret" "tsig" {
  path         = "k8s/cert-manager/tsig"
  disable_read = true
  data_json = jsonencode({
    "mareo.fr" = try(file("../secrets/dns_key"), "FIXME")
  })
}
