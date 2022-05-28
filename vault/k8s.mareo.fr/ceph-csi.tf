resource "vault_generic_secret" "ceph-csi_cephfs-secret" {
  path         = "k8s/ceph-csi/cephfs-secret"
  disable_read = true
  data_json = jsonencode({
    adminID  = "FIXME"
    adminKey = "FIXME"
  })
}

resource "vault_generic_secret" "ceph-csi_rbd-secret" {
  path         = "k8s/ceph-csi/rbd-secret"
  disable_read = true
  data_json = jsonencode({
    userID  = "FIXME"
    userKey = "FIXME"
  })
}
