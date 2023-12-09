#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH="" cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR"

echo "==> Configuring Nomad"

echo "    Creating and owning folders"
sudo mkdir -p "/opt/nomad/volumes/host"
sudo chown -R nomad:nomad "/opt/nomad/volumes"

echo "    Copying configuration"
sudo cp nomad.hcl /etc/nomad.d/nomad.hcl
sudo cp nomad.service "/lib/systemd/system/nomad.service"

echo "    Configuring systemd"

sudo systemctl daemon-reload
sudo systemctl enable nomad
sudo systemctl start nomad

echo "    Configuring Profile"

echo 'export "NOMAD_ADDR=http://localhost:4646"' >> .profile

echo "==> Nomad done"
