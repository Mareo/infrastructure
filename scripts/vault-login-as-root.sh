#!/bin/sh

set -e

BASEDIR="$(dirname "$0")/../"

VAULT_ADDR="$(shyaml get-value vault_addr < "${BASEDIR}/config.yml")"
export VAULT_ADDR

root_token="$(shyaml get-value root_token < "${BASEDIR}/secrets/vault.yml")"

echo "$root_token" | vault login -
