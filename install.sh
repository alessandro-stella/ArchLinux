#!/usr/bin/env bash
set -euo pipefail

echo "Esecuzione script..."

# esempio: installazione di un pacchetto
if ! command -v curl >/dev/null 2>&1; then
  echo "curl non installato"
  exit 1
fi

echo "Tutto ok"
