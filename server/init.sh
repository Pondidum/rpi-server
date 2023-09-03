#!/bin/sh

set -eu

# fix language when SSHing in
echo "export LC_ALL=C.UTF-8" >> "${HOME}/.profile"

sudo apt install -yq \
  gpg \
  jq

wget -O- https://apt.releases.hashicorp.com/gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update

sudo apt install -yq \
  nomad \
  vault
