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

sleep 2s

sudo systemctl status vault

echo "--> Vault running"

init=$(vault operator init -key-shares=1 -key-threshold=1 -format=json)

echo "    Initialised"

unseal_key=$(echo "${init}" | jq -r ".unseal_keys_b64[0]")
root_token=$(echo "${init}" | jq -r ".root_token")

echo "${unseal_key}" | sudo tee /opt/vault/unseal
echo "${root_token}" | sudo tee /opt/vault/root_token

echo "    Tokens saved"

vault operator unseal "${unseal_key}"

echo "--> Vault unsealed"

export VAULT_TOKEN="${root_token}"

echo "    Wriiting Policies"
vault policy write nomad policy.nomad.hcl
vault policy write kv policy.kv.hcl

echo "    Configuring Nomad integration"

vault write auth/token/roles/nomad token_period=1h

echo "    Enabling KV secrets engine"

vault secrets enable -version=2 kv

echo "    Writing password policy"

vault write sys/policies/password/default policy=@password_policy.hcl

echo "    Configuring Profile"

echo 'export "VAULT_ADDR=http://localhost:8200"' >> .profile

echo "==> Vault initialised"