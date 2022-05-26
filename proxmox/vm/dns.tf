resource "dns_a_record_set" "dns" {
  zone = "${var.dns_zone}."
  name = trimsuffix(var.name, ".${var.dns_zone}")

  addresses = [
    split("/", var.network_ip4)[0],
  ]
}
