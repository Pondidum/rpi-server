#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH="" cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR"

sudo mkdir -p "/opt/nomad/volumes/host"
sudo chown -R nomad:nomad "/opt/nomad/volumes"

sudo cp nomad.hcl /etc/nomad.d/nomad.hcl
sudo cp nomad.service "/lib/systemd/system/nomad.service"
sudo cp prestart.sh "/etc/nomad.d/prestart.sh"

sudo systemctl daemon-reload
sudo systemctl enable nomad
sudo systemctl start nomad