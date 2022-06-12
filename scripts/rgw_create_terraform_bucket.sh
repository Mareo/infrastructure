#!/bin/sh
set -e

BASEDIR="$(dirname "$0")/../"

TERRAFORM_BUCKET="$(shyaml get-value terraform_bucket < "${BASEDIR}/config.yml")"
S3_ENDPOINT_URL="$(shyaml get-value s3_endpoint_url < "${BASEDIR}/config.yml")"

AWS_ACCESS_KEY_ID="$(shyaml get-value access_key < "${BASEDIR}/secrets/rgw_user_admin.yml")"
AWS_SECRET_ACCESS_KEY="$(shyaml get-value secret_key < "${BASEDIR}/secrets/rgw_user_admin.yml")"
export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

aws s3api --endpoint-url="${S3_ENDPOINT_URL}" create-bucket --bucket "${TERRAFORM_BUCKET}" --acl private

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
