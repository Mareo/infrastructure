#!/bin/sh

set -e

BASEDIR="$(dirname "$0")/../"
VAULT_ADDR="$(shyaml get-value vault_addr < "${BASEDIR}/config.yml")"
export VAULT_ADDR

for key in $(shyaml get-value unseal_keys_b64 < "${BASEDIR}/secrets/vault.yml"); do
	if [ "$key" != "-" ]; then
		vault operator unseal "$key"
	fi
done
