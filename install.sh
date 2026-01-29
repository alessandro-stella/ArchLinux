#!/usr/bin/env bash
# --- UNIFIED SCRIPT (AUTO-GENERATED) ---

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

# Loop to keep sudo active
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo
echo "Starting install script..."

### --- START CONFIG.SH --- ###

# General configuration
GITHUB_LINK="https://github.com/alessandro-stella"
DOTFILES_FOLDER="dotfiles"
DOTFILES_REPO="$GITHUB_LINK/$DOTFILES_FOLDER"
INSTALL_SCRIPTS="scripts/install_scripts"
MONITOR_SETUP="monitor-setup.conf"
DYNAMIC_BORDER="dynamic-border.conf"

# Additional resources (wallpaper, .bashrc etc)
RESOURCES_FOLDER="dotfiles-resources"
SDDM_THEME="sdt"
SDDM_THEME_FOLDER="/usr/share/sddm/themes"

# Theme chooser configuration
DEFAULT_WALLPAPER="City-Rain.png"
SUDOERS_FILE="/etc/sudoers.d/sddm-wallpaper"
WALLPAPER_SOURCE="wallpaper/blurred_wallpaper.png"
SDDM_DEST="$SDDM_THEME_FOLDER/$SDDM_THEME/wallpaper.png"
THEME_CHOOSER_MAIN_SCRIPT="wallpaper_changer.sh"
THUMBNAIL_GENERATOR="generate_thumbnails.sh"

THEME_CHOOSER_DEPENDENCIES_PACMAN=(
   "imagemagick"
)

THEME_CHOOSER_DEPENDENCIES_YAY=(
   "wallust"
)

THEME_CHOOSER_SCRIPTS=(
  "$THEME_CHOOSER_MAIN_SCRIPT"
  "$THUMBNAIL_GENERATOR"
  "oh_my_posh_changer.sh"
  "palette_changer.sh"
  "theme_chooser.sh"
  "waybar_changer.sh"
)

# General packages and apps
PACMAN_PACKAGES=(
  "pacman-contrib"
  "git-lfs"
  "base-devel"
  "btop"
  "thunar"
  "waybar"
  "swaync"
  "libnotify"
  "unzip"
  "github-cli"
  "hyprshot"
  "loupe"
  "qt5-quickcontrols"
  "qt5-quickcontrols2"
  "qt6-wayland"
  "rsync"
  "tlp"
  "ufw"
  "yazi"
  "rofi"
  "jq"
  "bc"
  "ttf-jetbrains-mono-nerd"
  "imagemagick"
  "pamixer"
  "pavucontrol"
  "pmbootstrap"
  "network-manager-applet"
  "man-db"
  "gtk3"
  "gtk4"
  "gnome-themes-extra"
  "fastfetch"
)

YAY_PACKAGES=(
  "wallust"
  "swww"
  "brave-bin"
  "google-java-format"
  "oh-my-posh-bin"
  "wlogout"
  "wlogout-debug"
)

declare -A EXTERNAL_PACKAGES=(
  #["<NAME>"]="<URL>"
)

# Neovim configuration
NEOVIM_FOLDER="OrionVim"
NEOVIM_REPO="$GITHUB_LINK/$NEOVIM_FOLDER"

NEOVIM_PACKAGES=(
  "neovim"
  "tree-sitter-cli"
  "stylua"
  "python-black"
  "python-xlib"
  "lua-language-server"
  "maven"
  "tailwindcss-language-server"
  "vscode-html-languageserver"
  "rust"
  "go"
  "swi-prolog"
  "noto-fonts-emoji"
)
### --- END CONFIG.SH --- ###

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

    # Cloning or updating yay
    if [ ! -d "yay" ]; then
        sudo -u "$USER_NAME" git clone https://aur.archlinux.org/yay.git
    else
        echo "yay already cloned, handling ownership and updating..."
        sudo -u "$USER_NAME" git config --global --add safe.directory "$HOME/yay"
        cd yay
        sudo -u "$USER_NAME" git pull
        cd ..
    fi

    # Build and installation
    cd yay
    chown -R "$USER_NAME":"$USER_NAME" .
    sudo -u "$USER_NAME" makepkg -si --noconfirm
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
echo -n "Do you want to proceed with the installation? [y/N] "
read -r confirm < /dev/tty
confirm="${confirm,,}"

if [[ "$confirm" != "y" ]]; then
    echo "Installation aborted!"
    exit 0
fi

# Install pacman packages
PACMAN_TO_INSTALL=()

for pkg in "${PACMAN_PACKAGES[@]}"; do
    if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
        PACMAN_TO_INSTALL+=("$pkg")
    fi
done

if [ "${#PACMAN_TO_INSTALL[@]}" -gt 0 ]; then
    sudo pacman -S --noconfirm "${PACMAN_TO_INSTALL[@]}"
fi

# Install yay packages
YAY_TO_INSTALL=()

for pkg in "${YAY_PACKAGES[@]}"; do
    if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
        YAY_TO_INSTALL+=("$pkg")
    fi
done

if [ "${#YAY_TO_INSTALL[@]}" -gt 0 ]; then
    sudo -u "$USER_NAME" -H yay -S --noconfirm "${YAY_TO_INSTALL[@]}"
fi

# Install external packages
is_installed() {
    command -v "$1" >/dev/null 2>&1
}

for pkg in "${!EXTERNAL_PACKAGES[@]}"; do
    if is_installed "$pkg"; then
        echo "$pkg already installed, skipping"
        continue
    fi

    curl -fsSL "${EXTERNAL_PACKAGES[$pkg]}" | bash
done


# Download dotfiles

if [ -d "$DOTFILES_FOLDER" ]; then
    echo "Folder $DOTFILES_FOLDER already exists, updating..."
    cd "$RESOURCES_FOLDER" && git pull && cd ..
else
    git clone "$DOTFILES_REPO" "$DOTFILES_FOLDER"
fi

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
touch "$CONFIG/hypr/$MONITOR_SETUP"
echo "# Basic monitor configuration" > "$CONFIG/hypr/$MONITOR_SETUP"
echo "monitor = , preferred, auto, 1" >> "$CONFIG/hypr/$MONITOR_SETUP"

# Remove line from hyprland.conf
TARGET_FILE="$CONFIG/hypr/hyprland.conf"
LINE='exec-once = ~/.config/scripts/update_configs.sh # Pull remote changes to .config and nvim'
sed -i "\|$LINE|d" "$TARGET_FILE"

# Create dynamic border file (will be setup after by theme chooser)
touch "$CONFIG/hypr/$DYNAMIC_BORDER"

# Add exec permissions to all scripts
chmod -R +x "$CONFIG/scripts"

# Download repo with utility (Images, sddm theme, .bashrc)
if [ -d "$RESOURCES_FOLDER" ]; then
    echo "Folder $RESOURCES_FOLDER already exists, updating..."
    cd "$RESOURCES_FOLDER" && git pull && cd ..
else
    git clone "$GITHUB_LINK/$RESOURCES_FOLDER"
fi

# Move wallpapers
mkdir -p "$HOME/Pictures"
mkdir -p "$HOME/Pictures/Screenshots"
mv -n "$RESOURCES_FOLDER/wallpapers" "$HOME/Pictures/"

# Move SDDM theme
mv -n "$RESOURCES_FOLDER/$SDDM_THEME" "$SDDM_THEME_FOLDER/"

# Adding sudoers rule for theme changer
echo "$USER_NAME ALL=(root) NOPASSWD: /usr/bin/cp $CONFIG/$WALLPAPER_SOURCE $SDDM_DEST" > "$SUDOERS_FILE"
chmod 440 "$SUDOERS_FILE"

# Run script to choose a default theme

echo
echo "Configuring theme"
echo "Do you want to use a custom image? [y/N] "
read -r use_custom < /dev/tty
SELECTED_WALLPAPER="$HOME/Pictures/wallpapers/$DEFAULT_WALLPAPER"

if [[ "${use_custom,,}" == "y" ]]; then
    while true; do
        echo -n "Insert image path (like $HOME/Downloads/img.png): "
        read -r user_path < /dev/tty

        user_path="${user_path/#\~/$HOME}"

        if [[ -f "$user_path" ]]; then
            filename=$(basename "$user_path")
            dest_path="$HOME/Pictures/wallpapers/$filename"
            
            echo "Copying image..."
            cp "$user_path" "$dest_path"
            
            SELECTED_WALLPAPER="$dest_path"
            break
        else
            echo "Error: file not found. Try again"
        fi
    done
fi

# Run script to create thumbnails
source "$CONFIG/scripts/$THUMBNAIL_GENERATOR"

# Generate and apply theme
echo "Applying theme: $(basename "$SELECTED_WALLPAPER")"
source "$CONFIG/scripts/$THEME_CHOOSER_MAIN_SCRIPT" "$SELECTED_WALLPAPER"

# Moving and sourcing .bashrc
mv -n "$RESOURCES_FOLDER/.bashrc" "$HOME/"
source "$HOME/.bashrc"

# Set Adwaita-Dark
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Ask for neovim
echo -n "Do you want to configure OrionVim? [y/N] "
read -r confirm < /dev/tty
confirm="${confirm,,}"

if [[ "$confirm" == "y" ]]; then
  sudo rm -rf "$CONFIG/nvim"

  for pkg in "${NEOVIM_PACKAGES[@]}"; do
      echo "Installing $pkg..."
      sudo pacman -S --noconfirm "$pkg"
  done

  if [ ! -d "$CONFIG/nvim" ]; then
      echo "Cloning OrionVim repository..."
      sudo -u "$USER_NAME" git clone "$NEOVIM_REPO" "$CONFIG/nvim"
  else
      echo "Neovim configuration folder already exists. Skipping clone."
  fi
fi

# Ask for theme changer
echo -n "Do you want to keep the theme changer? [Y/n] "
read -r confirm_theme < /dev/tty
confirm_theme="${confirm_theme,,}"

if [[ "$confirm_theme" == "n" ]]; then
### --- START CLEANUP.SH --- ###

# Cleanup script if user dislikes the theme changer

rm -rf "$HOME/Pictures/wallpapers"
rm -rf "$CONFIG/wallust"


# Change kitty config
TARGET_FILE="$HOME/.config/kitty/kitty.conf"
SEARCH_LINE='include ~/.cache/wallust/colors-kitty.conf'
SOURCE_FILE="$HOME/.cache/wallust/colors-kitty.conf"
CONTENT=$(<"$SOURCE_FILE")


awk -v search="$SEARCH_LINE" -v replacement="$CONTENT" '
    $0 == search { print replacement; next }
    { print }
' "$TARGET_FILE" > "${TARGET_FILE}.tmp" && mv "${TARGET_FILE}.tmp" "$TARGET_FILE"


# Change rofi config
TARGET_FILE="$HOME/.config/rofi/config.rasi"
SEARCH_LINE='@theme "~/.cache/wallust/colors-rofi.rasi"'
SOURCE_FILE="$HOME/.cache/wallust/colors-rofi.rasi"
CONTENT=$(<"$SOURCE_FILE")

awk -v search="$SEARCH_LINE" -v replacement="$CONTENT" '
    $0 == search { print replacement; next }
    { print }
' "$TARGET_FILE" > "${TARGET_FILE}.tmp" && mv "${TARGET_FILE}.tmp" "$TARGET_FILE"


# Remove templates
rm -f "$CONFIG/waybar/template.css"
rm -f "$CONFIG/wlogout/template.css"
rm -f "$CONFIG/oh-my-posh/themes/themeTemplate.omp.json"


# Change hyprland border
TARGET_FILE="$CONFIG/hypr/hyprland.conf"
SEARCH_LINE='source = ~/.config/hypr/dynamic-border.conf'
SOURCE_FILE="$HOME/.config/hypr/dynamic-border.conf"
CONTENT=$(<"$SOURCE_FILE")

awk -v search="$SEARCH_LINE" -v replacement="$CONTENT" '
    $0 == search { print replacement; next }
    { print }
' "$TARGET_FILE" > "${TARGET_FILE}.tmp" && mv "${TARGET_FILE}.tmp" "$TARGET_FILE"

SEARCH_LINE='bind = $mainMod SHIFT, T, exec, sh $HOME/.config/scripts/theme_chooser.sh # Change theme based on wallpaper'
sed -i "\|$SEARCH_LINE|d" "$TARGET_FILE"


# Remove pacman dependencies
for pkg in "${THEME_CHOOSER_DEPENDENCIES_PACMAN[@]}"; do
    sudo pacman -Rs --noconfirm "$pkg"
done


# Remove yay dependencies
for pkg in "${THEME_CHOOSER_DEPENDENCIES_YAY[@]}"; do
    sudo -u "$USER_NAME" -H yay -R --noconfirm "$pkg"
done


# Removing useless scripts
for script in "${THEME_CHOOSER_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
      rm -f "$script"
    fi
done


# Removing sudoers rule
if [ -f "$SUDOERS_FILE" ]; then
    rm -f "$SUDOERS_FILE"
fi
### --- END CLEANUP.SH --- ###
fi

# Enable and start TLP
echo "Enabling and starting TLP..."
systemctl enable tlp.service
systemctl start tlp.service

# Enable and start UFW
echo "Enabling and starting UFW..."
systemctl enable ufw.service
systemctl start ufw.service

# Set default firewall rules (deny incoming, allow outgoing)
ufw default deny incoming
ufw default allow outgoing
ufw --force enable

# Give user all permissions over copied files
chown -R "$USER_NAME":"$USER_NAME" "$CONFIG"
chown -R "$USER_NAME":"$USER_NAME" "$HOME/Pictures"

# Delete installation script
sudo rm "$CONFIG/install.sh"
sudo rm "$CONFIG/README.md"
sudo rm "$CONFIG/QtProject.conf"

# Clean sudo refresh added at the start
kill $(jobs -p) 2>/dev/null || true

echo
echo "Installation completed!"

echo -n "Do you want to reboot (suggested)? [Y/n] "
read -r confirm < /dev/tty
confirm="${confirm,,}"

if [[ "$confirm" != "n" ]]; then
    echo "Rebooting system now..."
    reboot
fi

echo "Enjoy your new setup!"
