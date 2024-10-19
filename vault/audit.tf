resource "vault_audit" "audit" {
  type = "file"
  path = "stdout"
  options = {
    file_path = "/dev/stdout"
  }
}
