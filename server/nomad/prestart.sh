#!/bin/sh

set -eu

export "VAULT_ADDR=http://localhost:8200"
export "VAULT_TOKEN=$(cat /opt/vault/root_token)"

token="$(vault token create -field=token -role=nomad)"

echo "VAULT_TOKEN=${token}" > /etc/nomad.d/nomad.env
