#!/bin/sh

set -eu

export "VAULT_ADDR=http://localhost:8200"
export "VAULT_TOKEN=$(cat /srv/vault/root_token)"

password=$(vault kv get -mount=kv -field=password apps/postgres/super)
username=$(vault kv get -mount=kv -field=username apps/postgres/super)

echo "user: ${username}, pass: ${password}"

export "PGPASSWORD=${password}"
export "PGUSER=${username}"
export "PGDBNAME=postgres"
export "PGHOST=192.168.1.178"

role_password=$(vault read -field=password sys/policies/password/default/generate)
echo "pass: ${role_password}"

psql -c "create role vaultadmin with Login password '${role_password}' CreateRole;"
psql -c "grant connect on database postgres to vaultadmin;"

vault secrets enable database
vault write database/config/postgres \
  plugin_name=postgresql-database-plugin \
  allowed_roles="*" \
  connection_url="postgresql://{{username}}:{{password}}@${PGHOST}:5432/postgres?sslmode=disable" \
  username="vaultadmin" \
  password="${role_password}"
