#!/bin/sh

TERRAFORM_BUCKET="$(shyaml get-value terraform_bucket < "${BASEDIR}/config.yml")"
S3_ENDPOINT_URL="$(shyaml get-value s3_endpoint_url < "${BASEDIR}/config.yml")"

AWS_ACCESS_KEY_ID="$(shyaml get-value access_key < "${BASEDIR}/secrets/rgw_user_admin.yml")"
AWS_SECRET_ACCESS_KEY="$(shyaml get-value secret_key < "${BASEDIR}/secrets/rgw_user_admin.yml")"
export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

aws s3api --endpoint-url="${S3_ENDPOINT_URL}" create-bucket --bucket "${TERRAFORM_BUCKET}" --acl private
