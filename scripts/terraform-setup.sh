#!/bin/sh
set -e

BASEDIR="$(realpath "$(dirname "$0")/..")"

TERRAFORM_BUCKET="$(shyaml get-value terraform_bucket < "${BASEDIR}/config.yml")"
S3_ENDPOINT_URL="$(shyaml get-value s3_endpoint_url < "${BASEDIR}/config.yml")"

AWS_ACCESS_KEY_ID="$(shyaml get-value access_key < "${BASEDIR}/secrets/rgw_user_terraform.yml")"
AWS_SECRET_ACCESS_KEY="$(shyaml get-value secret_key < "${BASEDIR}/secrets/rgw_user_terraform.yml")"

cat > "${BASEDIR}/secrets/terraform_config" <<EOF
region     = "ceph"
endpoint   = "${S3_ENDPOINT_URL}"
access_key = "${AWS_ACCESS_KEY_ID}"
secret_key = "${AWS_SECRET_ACCESS_KEY}"
bucket     = "${TERRAFORM_BUCKET}"

skip_credentials_validation = true
skip_region_validation      = true
force_path_style            = true
EOF

for dir in authentik discord gitlab proxmox vault; do
	terraform -chdir="${BASEDIR}/${dir}" init -backend-config="${BASEDIR}/secrets/terraform_config" -upgrade -reconfigure
done
