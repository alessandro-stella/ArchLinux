#!/usr/bin/env bash
set -euo pipefail

echo "Starting install script..."

# esempio: installazione di un pacchetto
if ! command -v curl >/dev/null 2>&1; then
  echo "curl non installed"
  exit 1
fi

source ./config.sh
echo "User: $USERNAME"
echo "Password: $PASSWORD"
echo "Install dir: $INSTALL_DIR"
