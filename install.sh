#!/usr/bin/env bash
set -euo pipefail

echo "\nStarting install script..."

# esempio: installazione di un pacchetto
if ! command -v curl >/dev/null 2>&1; then
  echo "curl non installed"
  exit 1
fi

source ./config.sh

echo "Pacchetti standard da installare:"
for pkg in "${PACKAGES[@]}"; do
    echo " - $pkg"
done

echo
echo "Pacchetti esterni da installare:"
for pkg in "${!EXTERNAL_PACKAGES[@]}"; do
    echo " - $pkg -> ${EXTERNAL_PACKAGES[$pkg]}"
done

echo
# Chiedi conferma
read -rp "Vuoi procedere con l'installazione? [y/N] " confirm
confirm="${confirm,,}"  # lowercase

if [[ "$confirm" != "y" ]]; then
    echo "Installazione annullata."
    exit 0
fi

# Installazione pacchetti standard
for pkg in "${PACKAGES[@]}"; do
    echo "Installazione di $pkg..."
    sudo pacman -S --noconfirm "$pkg"
done

# Installazione pacchetti esterni
for pkg in "${!EXTERNAL_PACKAGES[@]}"; do
    url="${EXTERNAL_PACKAGES[$pkg]}"
    echo "Installazione di $pkg da $url..."
    curl -fsSL "$url" | bash
done

echo "Installazione completata."
