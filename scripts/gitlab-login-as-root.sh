#!/bin/sh

set -e

BASEDIR="$(realpath "$(dirname "$0")/..")"

VAULT_ADDR="$(shyaml get-value vault_addr < "${BASEDIR}/config.yml")"
export VAULT_ADDR

GITLAB_ADDR="$(shyaml get-value gitlab_addr < "${BASEDIR}/config.yml")"
GITLAB_ROOT_PASSWORD="$(vault kv get -field=password k8s/gitlab/initial-root-password)"

oauth_token="$(curl --silent --request POST "${GITLAB_ADDR}/oauth/token" \
  --data-urlencode "grant_type=password" \
  --data-urlencode "username=root" \
  --data-urlencode "password=${GITLAB_ROOT_PASSWORD}")"

echo "${oauth_token}" | jq -r .access_token > "${BASEDIR}/secrets/gitlab_token"
echo "GitLab token saved to ${BASEDIR}/secrets/gitlab_token"
