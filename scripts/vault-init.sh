#!/bin/sh

set -e

BASEDIR="$(dirname "$0")/../"

VAULT_ADDR="$(shyaml get-value vault_addr < "${BASEDIR}/config.yml")"
export VAULT_ADDR

if vault_keys="$(vault operator init -key-shares=1 -key-threshold=1 -format=yaml)"; then
    echo "$vault_keys" > "${BASEDIR}/secrets/vault.yml"
fi
