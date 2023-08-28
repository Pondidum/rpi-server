#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH="" cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR"

# move the config to where vault will look for it
sudo cp vault.hcl /etc/vault.d/vault.hcl

sudo systemctl enable vault.service
sudo systemctl start vault.service

export VAULT_ADDR=http://localhost:8200

echo "==> Waiting for vault to start"

while [ "$(vault status 1>/dev/null && echo "0" || echo "$?")" -eq 1 ]; do
  echo "    not running, sleeping 2s"
  sleep 2s
done

echo "--> Vault running"

init=$(vault operator init -key-shares=1 -key-threshold=1 -format=json)

unseal_key=$(echo "${init}" | jq -r ".unseal_keys_b64[0]")
root_token=$(echo "${init}" | jq -r ".root_token")

echo "${unseal_key}" | sudo tee /opt/vault/unseal
echo "${root_token}" | sudo tee /opt/vault/root_token

vault operator unseal "${unseal_key}"

export VAULT_TOKEN="${root_token}"

vault policy write nomad policy.nomad.hcl
vault policy write kv policy.kv.hcl

vault write auth/token/roles/nomad token_period=1h

vault secrets enable -version=2 kv

vault write sys/policies/password/default policy=@password_policy.hcl
