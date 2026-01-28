#!/usr/bin/env bash
set -euo pipefail

echo "\nStarting install script..."

# esempio: installazione di un pacchetto
if ! command -v curl >/dev/null 2>&1; then
  echo "curl non installed"
  exit 1
fi

source ./config.sh

cd "$HOME" || exit 1
echo "Current working directory: $PWD"

# Check yay
if ! command -v yay >/dev/null 2>&1; then
    echo "yay not found, proceeding with installation..."

    # Cloning yay
    if [ ! -d "yay" ]; then
        git clone https://aur.archlinux.org/yay.git
    else
        echo "yay already cloned, updating..."
        cd yay
        git pull
        cd ..
    fi

    # Building and installing
    cd yay
    makepkg -si --noconfirm
    cd "$HOME"
fi

# Pacman packages
echo "Pacman packages:"
for pkg in "${PACMAN_PACKAGES[@]}"; do
    echo " - $pkg"
done

# Yay packages

# External packages
echo
echo "External packages to install:"
for pkg in "${!EXTERNAL_PACKAGES[@]}"; do
    echo " - $pkg -> ${EXTERNAL_PACKAGES[$pkg]}"
done

echo
# Ask confirm
read -rp "Do you want to proceed with the installation? [y/N] " confirm
confirm="${confirm,,}"  # lowercase

if [[ "$confirm" != "y" ]]; then
    echo "Installation aborted!"
    exit 0
fi

# Installing pacman packages
for pkg in "${PACMAN_PACKAGES[@]}"; do
    echo "Installazione di $pkg..."
    sudo pacman -S --noconfirm "$pkg"
done

# Installing external packages
for pkg in "${!EXTERNAL_PACKAGES[@]}"; do
    url="${EXTERNAL_PACKAGES[$pkg]}"
    echo "Installazione di $pkg da $url..."
    curl -fsSL "$url" | bash
done

echo "Installation completed, enjoy!"
