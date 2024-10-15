#!/bin/sh
set -e

BASEDIR="$(realpath "$(dirname "$0")/..")"

S3_ENDPOINT_URL="$(shyaml get-value s3_endpoint_url < "${BASEDIR}/config.yml")"

AWS_ACCESS_KEY_ID="$(shyaml get-value access_key < "${BASEDIR}/secrets/rgw_user_foundry.yml")"
AWS_SECRET_ACCESS_KEY="$(shyaml get-value secret_key < "${BASEDIR}/secrets/rgw_user_foundry.yml")"
export AWS_SECRET_ACCESS_KEY AWS_ACCESS_KEY_ID

buckets=$(aws s3api list-buckets --endpoint-url="${S3_ENDPOINT_URL}" | jq -r '.Buckets.[].Name')

for bucket in ${buckets}; do
    aws s3api put-bucket-cors --endpoint-url="${S3_ENDPOINT_URL}" \
        --bucket="${bucket}" \
        --cors-configuration="file://${BASEDIR}/scripts/foundry-cors.json"
done
