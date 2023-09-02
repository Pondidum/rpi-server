#!/bin/sh

vault kv put \
  -mount=kv /apps/postgres/super \
  "username=postgres" \
  "password=$(vault read -field=password sys/policies/password/default/generate)"
