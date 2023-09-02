#!/bin/sh

set -eu

export "VAULT_ADDR=http://localhost:8200"
export "VAULT_TOKEN=$(cat /opt/vault/root_token)"

password=$(vault kv get -mount=kv -field=password apps/postgres/super)
username=$(vault kv get -mount=kv -field=username apps/postgres/super)

echo "==> Configuring Postgres"

echo "    Looking up service"

address=$(nomad service info -json postgres | jq -r '.[0].Address')

echo "    Address: ${address}"

export "PGPASSWORD=${password}"
export "PGUSER=${username}"
export "PGDBNAME=postgres"
export "PGHOST=${address}"

echo "--> Generating password for Vault"

role_password=$(vault read -field=password sys/policies/password/default/generate)

echo "    Creating vaultadmin role"
psql -c "create role vaultadmin with Login password '${role_password}' CreateRole;"
psql -c "grant connect on database postgres to vaultadmin;"

echo "--> Configuring Vault"

echo "    Enabling database secrets engine"
vault secrets enable database

echo "    Configuring postgres integration"
vault write database/config/postgres \
  plugin_name=postgresql-database-plugin \
  allowed_roles="*" \
  connection_url="postgresql://{{username}}:{{password}}@${PGHOST}:5432/postgres?sslmode=disable" \
  username="vaultadmin" \
  password="${role_password}"

echo "   Creating reader role"
vault write database/roles/reader \
  db_name=postgres \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
      GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="10m" \
  max_ttl="1h"

echo "==> Done"
