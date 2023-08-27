# Allow creating tokens under "nomad" token role. The token role name
# should be updated if "nomad" is not used.
path "auth/token/create/nomad" {
  capabilities = ["update"]
}

# Allow looking up "nomad" token role. The token role name should be
# updated if "nomad" is not used.
path "auth/token/roles/nomad" {
  capabilities = ["read"]
}

# Allow looking up the token passed to Nomad to validate # the token has the
# proper capabilities. This is provided by the "default" policy.
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow looking up incoming tokens to validate they have permissions to access
# the tokens they are requesting. This is only required if
# `allow_unauthenticated` is set to false.
path "auth/token/lookup" {
  capabilities = ["update"]
}

# Allow revoking tokens that should no longer exist. This allows revoking
# tokens for dead tasks.
path "auth/token/revoke-accessor" {
  capabilities = ["update"]
}

# Allow checking the capabilities of our own token. This is used to validate the
# token upon startup.
path "sys/capabilities-self" {
  capabilities = ["update"]
}

# Allow our own token to be renewed.
path "auth/token/renew-self" {
  capabilities = ["update"]
}

# allow configuration of the nomad auth backend
path "nomad/config/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "nomad/role/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}