#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "Error at line $LINENO. Aborting."; exit 1' ERR

# Check if user used sudo to run the script
if [ "$EUID" -ne 0 ]; then
    echo "You need sudo permissions to run this script!"
    exit 1
fi

if [ -z "$SUDO_USER" ]; then
    echo "Error: could not recognize the user who run this script"
    exit 1
fi

# Defining local variables
USER_NAME="$SUDO_USER"
HOME="/home/$USER_NAME"
CONFIG="$HOME/.config"

echo
echo "Starting install script..."

source ./config.sh

cd "$HOME" || exit 1
echo "Current working directory: $PWD"

# Check git
if ! command -v git >/dev/null 2>&1; then
    echo "git not found, proceeding with installation..."
    sudo pacman -S --noconfirm git
fi

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

    # Build and installation
    cd yay
    makepkg -si --noconfirm
    cd "$HOME"
fi

# Pacman packages
if [ "${#PACMAN_PACKAGES[@]}" -gt 0 ]; then
    echo
    echo "Pacman packages:"

    for ((i=0; i<${#PACMAN_PACKAGES[@]}; i+=2)); do
        pkg1="${PACMAN_PACKAGES[i]}"
        pkg2="${PACMAN_PACKAGES[i+1]:-}"
        printf "%-25s %-25s\n" "$pkg1" "$pkg2"
    done
fi

# Yay packages
if [ "${#YAY_PACKAGES[@]}" -gt 0 ]; then
    echo
    echo "Yay packages:"

    for ((i=0; i<${#YAY_PACKAGES[@]}; i+=2)); do
        pkg1="${YAY_PACKAGES[i]}"
        pkg2="${YAY_PACKAGES[i+1]:-}"
        printf "%-25s %-25s\n" "$pkg1" "$pkg2"
    done
fi

# External packages
if [ "${#EXTERNAL_PACKAGES[@]}" -gt 0 ]; then
    echo
    echo "External packages to install:"
    for pkg in "${!EXTERNAL_PACKAGES[@]}"; do
        echo " - $pkg -> ${EXTERNAL_PACKAGES[$pkg]}"
    done
fi

echo

# Ask confirm
read -rp "Do you want to proceed with the installation? [y/N] " confirm
confirm="${confirm,,}"

if [[ "$confirm" != "y" ]]; then
    echo "Installation aborted!"
    exit 0
fi

# Install pacman packages
for pkg in "${PACMAN_PACKAGES[@]}"; do
    echo "Installing $pkg..."
    sudo pacman -S --noconfirm "$pkg"
done

# Install yay packages
for pkg in "${YAY_PACKAGES[@]}"; do
    echo "Installing $pkg..."
    yay -S --noconfirm "$pkg"
done

# Install external packages
for pkg in "${!EXTERNAL_PACKAGES[@]}"; do
    url="${EXTERNAL_PACKAGES[$pkg]}"
    echo "Installing $pkg from $url..."
    curl -fsSL "$url" | bash
done

# Download dotfiles
git clone "$DOTFILES_REPO" "$DOTFILES_FOLDER"

for item in "$DOTFILES_FOLDER"/*; do
    name=$(basename "$item")

    if [ -d "$item" ]; then
        # Remove existing folder in ~/.config
        if [ -d "$CONFIG/$name" ]; then
            echo "Replacing $CONFIG/$name"
            rm -rf "$CONFIG/$name"
        fi

        # Copy folder
        echo "Moving directory $name in $CONFIG"
        mv "$item" "$CONFIG/"

    elif [ -f "$item" ]; then
        # Remove existing file
        if [ -f "$CONFIG/$name" ]; then
            echo "Replacing file $CONFIG/$name"
            rm -f "$CONFIG/$name"
        fi

        # Move file
        echo "Moving $name in $CONFIG"
        mv "$item" "$CONFIG/"
    fi
done

rm -rf "$DOTFILES_FOLDER"
rm -rf "$CONFIG/$INSTALL_SCRIPTS"

# Create basic monitor configuration for hyprland
touch "$MONITOR_SETUP"
echo "# Basic monitor configuration" > "$MONITOR_SETUP"
echo "monitor = , preferred, auto, 1" >> "$MONITOR_SETUP"

# Remove line from hyprland.conf
TARGET_FILE="$CONFIG/hypr/hyprland.conf"
LINE='exec-once = ~/.config/scripts/update_configs.sh # Pull remote changes to .config and nvim'
sed -i "\|$LINE|d" "$TARGET_FILE"

# Create dynamic border file (will be setup after by theme chooser)
touch "$DYNAMIC_BORDER"

# Add exec permissions to all scripts
chmod +x "$CONFIG/scripts/*"

# Download repo with utility (Images, sddm theme, .bashrc)
git clone "$GITHUB_LINK/$RESOURCE_FOLDER"

# Move wallpapers
mkdir -p "$HOME/Pictures"
mkdir -p "$HOME/Pictures/Screenshots"
mv -n "$RESOURCE_FOLDER/wallpapers" "$HOME/Pictures/"

# Run script to create thumbnails
source "$CONFIG/scripts/$THUMBNAIL_GENERATOR"

# Move SDDM theme
mv -n "$RESOURCE_FOLDER/$SDDM_THEME" "$SDDM_THEME_FOLDER/"

# Adding sudoers rule for theme changer
echo "$USER_NAME ALL=(root) NOPASSWD: /usr/bin/cp $WALLPAPER_SOURCE $SDDM_DEST" > "$SUDOERS_FILE"
chmod 440 "$SUDOERS_FILE"

# Run script to shoose theme
source "$CONFIG/scripts/$THEME_CHOOSER_MAIN_SCRIPT"

# Moving and sourcing .bashrc
mv -n "$RESOURCE_FOLDER/.bashrc" "$HOME/"
source "$HOME/.bashrc"

# Set Adwaita-Dark
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Ask for neovim
read -rp "Do you want to configure OrionVim? [y/N] " confirm
confirm="${confirm,,}"

if [[ "$confirm" == "y" ]]; then
  # Install neovim packages
  for pkg in "${NEOVIM_PACKAGES[@]}"; do
      echo "Installing $pkg..."
      sudo pacman -S --noconfirm "$pkg"
  done

  # Clone git repo
  git clone "$NEOVIM_REPO" "$CONFIG/nvim"
fi

# Ask for theme changer
read -rp "Do you want to keep the theme changer? [Y/n] " confirm
confirm_theme="${confirm_theme,,}"  # lowercase

if [[ "$confirm_theme" == "n" ]]; then
    source "cleanup.sh"   
fi

echo
echo "Installation completed!"
read -rp "Do you want to reboot (suggested)? [Y/n] " confirm
confirm="${confirm,,}"

if [[ "$confirm" != "n" ]]; then
  # Reboot
fi

echo "Enjoy your new setup!"
