#!/bin/sh

set -eu

export VAULT_ADDR=http://localhost:8200

init=$(vault operator init -key-shares=1 -key-threshold=1 -format=json)

unseal_key=$(echo "${init}" | jq -r ".unseal_keys_b64[0]")
root_token=$(echo "${init}" | jq -r ".root_token")

echo "${unseal_key}" | sudo tee /srv/vault/unseal
echo "${root_token}" | sudo tee /srv/vault/root_token

vault operator unseal "${unseal_key}"

export VAULT_TOKEN="${root_token}"

vault policy write nomad policy.nomad.hcl
vault policy write kv policy.kv.hcl

vault write auth/token/roles/nomad token_period=1h

vault secrets enable -version=2 kv

vault write sys/policies/password/default policy=@password_policy.hcl
