#!/bin/sh

set -e

BASEDIR="$(dirname "$0")/../"

export VAULT_ADDR="$(shyaml get-value vault_addr < "${BASEDIR}/config.yml")"

root_token="$(shyaml get-value root_token < "${BASEDIR}/secrets/vault.yml")"

echo "$root_token" | vault login -
