#!/bin/sh

set -e

BASEDIR="$(dirname "$0")/../"

export VAULT_ADDR="$(shyaml get-value vault_addr < "${BASEDIR}/config.yml")"

vault_keys="$(vault operator init -key-shares=1 -key-threshold=1 -format=yaml)"

if [ $? -eq 0 ]; then
	echo "$vault_keys" > "${BASEDIR}/secrets/vault.yml"
fi
