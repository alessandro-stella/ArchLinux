#!/usr/bin/env bash
# === UNIFIED SCRIPT (AUTO-GENERATED) ===


set -Eeuo pipefail
trap 'echo "Error at line $LINENO. Aborting."; exit 1' ERR

# Utility functions
spinner() {
    local pid=$1
    local msg=$2
    local spinstr='|/-\'
    printf "%s  " "$msg"
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf "[%c]" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep 0.1
        printf "\b\b\b"
    done

    wait "$pid"
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        printf "\r%s  [DONE]\033[K\n" "$msg"
    else
        printf "\r%s  [FAILED]\033[K\n" "$msg"
        return 1
    fi
}

execute_silent() {
    local msg=$1
    shift
    "$@" > /dev/null 2>&1 &
    spinner $! "$msg" || exit 1
}

install_pkg() {
    local manager=$1
    shift
    local pkgs=("$@")
    local total=${#pkgs[@]}
    local count=0

    for pkg in "${pkgs[@]}"; do
        count=$((count + 1))
        percent=$((count * 100 / total))
        echo -ne "\r[${percent}%] Installing package: ${pkg}..."
        
        if [ "$manager" == "pacman" ]; then
            sudo pacman -S --noconfirm "$pkg" > /dev/null 2>&1
        else
            sudo -u "$USER_NAME" -H yay -S --noconfirm "$pkg" > /dev/null 2>&1
        fi
        
        echo -ne "\r\033[K" 
    done
    echo -e "\r[100%] Installation of $manager packages completed."
}

# ============================
# Start of installation script
# ============================


# Check if user used sudo to run the script
if [ "$EUID" -ne 0 ]; then
    echo "You need sudo permissions to run this script!"
    exit 1
fi

if [ -z "$SUDO_USER" ]; then
    echo "Error: could not recognize the user who ran this script"
    exit 1
fi


# Clean start
clear


# Defining local variables
USER_NAME="$SUDO_USER"
HOME="/home/$USER_NAME"
CONFIG="$HOME/.config"


# Try to recover the signature if not explicitly passed
if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  echo
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "CRITICAL ERROR: HYPRLAND_INSTANCE_SIGNATURE variable not found."
  echo "Unable to communicate with Hyprland from this sudo session."
  echo
  echo "Please relaunch the script using this command:"
  echo "curl -fsSL https://raw.githubusercontent.com/alessandro-stella/dotfiles/master/install.sh | sudo HYPRLAND_INSTANCE_SIGNATURE=\$HYPRLAND_INSTANCE_SIGNATURE bash"
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo
  exit 1
fi


# Loop to keep sudo privileges active
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo
echo "Starting install script..."

### === START CONFIG.SH === ###

# General configuration
GITHUB_LINK="https://github.com/alessandro-stella"
DOTFILES_FOLDER="dotfiles"
DOTFILES_REPO="$GITHUB_LINK/$DOTFILES_FOLDER"
INSTALL_SCRIPTS="scripts/install_scripts"
CUSTOM_SETTINGS="device-settings.conf"
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
THEME_CHANGER_MAIN_SCRIPT="theme_changer/wallpaper_changer.sh"
THUMBNAIL_GENERATOR="generate_thumbnails.sh"

THEME_CHANGER_DEPENDENCIES_PACMAN=(
   "imagemagick"
)

THEME_CHANGER_DEPENDENCIES_YAY=(
   "wallust"
)

THEME_CHANGER_SCRIPTS="theme_changer"

# General packages and apps
PACMAN_PACKAGES=(
  "xdg-desktop-portal-gtk"
  "adw-gtk-theme"
  "pacman-contrib"
  "git-lfs"
  "base-devel"
  "btop"
  "waybar"
  "swaync"
  "libnotify"
  "unzip"
  "github-cli"
  "hyprshot"
  "loupe"
  "qt5-graphicaleffects"
  "qt5-quickcontrols"
  "qt5-quickcontrols2"
  "qt5-virtualkeyboard"
  "qt5-wayland"
  "qt6-5compat"
  "qt6-declarative"
  "qt6-virtualkeyboard"
  "qt6-wayland"
  "kirigami-addons"
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
  "brightnessctl"
  "blueman"
  "nautilus"
  "gvfs"
  "gvfs-mtp"
  "udisks2"
  "ntfs-3g"
  "evince"
  "libreoffice-still"
  "libreoffice-still-it"
  "npm"
  "jdk-openjdk"
  "neovim"
)

YAY_PACKAGES=(
  "wallust"
  "swww"
  "brave-bin"
  "google-java-format"
  "oh-my-posh-bin"
  "wlogout"
  "wlogout-debug"
  "swaylock-effects-git"
)

declare -A EXTERNAL_PACKAGES=(
  #["<NAME>"]="<URL>"
)

# Neovim configuration
NEOVIM_FOLDER="OrionVim"
NEOVIM_REPO="$GITHUB_LINK/$NEOVIM_FOLDER"

NEOVIM_PACKAGES=(
  "tree-sitter-cli"
  "stylua"
  "python-black"
  "python-xlib"
  "lua-language-server"
  "maven"
  "tailwindcss-language-server"
  "vscode-html-languageserver"
  "noto-fonts-emoji"
)
### === END CONFIG.SH === ###

cd "$HOME" || exit 1
echo "Current working directory: $PWD"


# Check git
if ! command -v git >/dev/null 2>&1; then
    execute_silent "Installing git" sudo pacman -S --noconfirm git
fi


# Check yay
if ! command -v yay >/dev/null 2>&1; then
    echo "Installing yay..."
    if [ ! -d "yay" ]; then
        sudo -u "$USER_NAME" git clone https://aur.archlinux.org/yay.git > /dev/null 2>&1
    fi
    cd yay
    chown -R "$USER_NAME":"$USER_NAME" .
    execute_silent "Building yay (this may take a while)" sudo -u "$USER_NAME" makepkg -si --noconfirm
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
    echo "Starting Pacman installation..."
    install_pkg "pacman" "${PACMAN_TO_INSTALL[@]}"
fi


# Install yay packages
YAY_TO_INSTALL=()

for pkg in "${YAY_PACKAGES[@]}"; do
    if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
        YAY_TO_INSTALL+=("$pkg")
    fi
done

if [ "${#YAY_TO_INSTALL[@]}" -gt 0 ]; then
    echo "Starting Yay installation..."
    install_pkg "yay" "${YAY_TO_INSTALL[@]}"
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


# --- Download dotfiles ---
echo
rm -rf "$DOTFILES_FOLDER"

execute_silent "Downloading dotfiles" git clone "$GITHUB_LINK/$DOTFILES_FOLDER"

if [ ! -d "$DOTFILES_FOLDER" ]; then
    echo "Error: Failed to download dotfiles. Check your internet connection."
    exit 1
fi

items=("$DOTFILES_FOLDER"/*)
total_items=${#items[@]}
current_item=0

echo "Deploying configurations..."

for item in "${items[@]}"; do
    name=$(basename "$item")
    current_item=$((current_item + 1))
    percent=$((current_item * 100 / total_items))

    printf "\r[%d%%] Moving: %s\033[K" "$percent" "$name"

    {
        if [ -e "$CONFIG/$name" ]; then
            rm -rf "$CONFIG/$name"
        fi
        mv "$item" "$CONFIG/"
    } > /dev/null 2>&1
done

printf "\r[100%%] Configurations deployed.\n"
rm -rf "$HOME/$DOTFILES_FOLDER"


# Configure per-device settings
touch "$CONFIG/hypr/$CUSTOM_SETTINGS"
echo "# Basic monitor configuration" > "$CONFIG/hypr/$CUSTOM_SETTINGS"
echo "monitor = , preferred, auto, 1" >> "$CONFIG/hypr/$CUSTOM_SETTINGS"

# Remove line from hyprland.conf
TARGET_FILE="$CONFIG/hypr/hyprland.conf"
LINE='exec-once = ~/.config/scripts/update_configs.sh # Pull remote changes to .config and nvim'
sed -i "\|$LINE|d" "$TARGET_FILE"

# Create dynamic border file (will be setup after by theme chooser)
touch "$CONFIG/hypr/$DYNAMIC_BORDER"

# Add exec permissions to all scripts
chmod -R +x "$CONFIG/scripts"


# Download additional resources
echo
rm -rf "$RESOURCES_FOLDER"

execute_silent "Refreshing resources" git clone "$GITHUB_LINK/$RESOURCES_FOLDER"

if [ ! -d "$RESOURCES_FOLDER" ]; then
    echo "Error: Failed to download resources. Check your internet connection."
    exit 1
fi

echo "Installing system assets and wallpapers... "

{
    # Create necessary directories
    mkdir -p "$HOME/Pictures/Screenshots"

    # Move wallpapers
    mv -n "$RESOURCES_FOLDER/wallpapers" "$HOME/Pictures/"

    # Install and configure SDDM theme
    mv -n "$RESOURCES_FOLDER/$SDDM_THEME" "$SDDM_THEME_FOLDER/"
    echo -e "[Theme]\nCurrent=$SDDM_THEME" | tee /etc/sddm.conf

    # Override current .bashrc and fix ownership
    mv -f "$RESOURCES_FOLDER/.bashrc" "$HOME/"
    chown "$USER_NAME":"$USER_NAME" "$HOME/.bashrc"

    # Add sudoers rule for the theme changer script
    echo "$USER_NAME ALL=(root) NOPASSWD: /usr/bin/cp $CONFIG/$WALLPAPER_SOURCE $SDDM_DEST" > "$SUDOERS_FILE"
    chmod 440 "$SUDOERS_FILE"

    # Clean up temporary resource folder
    rm -rf "$HOME/$RESOURCES_FOLDER"
} > /dev/null 2>&1

echo "Done"


# Run script to choose a theme
echo
echo "Configuring theme"
echo -n "Do you want to use a custom image? [y/N] "
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


# Start wallpaper and notification daemon
sudo -u "$USER_NAME" -H HYPRLAND_INSTANCE_SIGNATURE="$HYPRLAND_INSTANCE_SIGNATURE" hyprctl dispatch exec "swww-daemon"
sudo -u "$USER_NAME" -H HYPRLAND_INSTANCE_SIGNATURE="$HYPRLAND_INSTANCE_SIGNATURE" hyprctl dispatch exec "swaync"
sleep 1


# Give user all permissions over copied files
chown -R "$USER_NAME":"$USER_NAME" "$CONFIG"
chown -R "$USER_NAME":"$USER_NAME" "$HOME/Pictures"


# Generate and apply theme
echo
echo "Applying theme: $(basename "$SELECTED_WALLPAPER")"

if ! sudo -u "$USER_NAME" -H "$CONFIG/scripts/$THEME_CHANGER_MAIN_SCRIPT" "$SELECTED_WALLPAPER"; then
    echo "Warning: Theme chooser encountered an issue, but continuing installation..."
fi

echo "Fixing cache permissions..."
chown -R "$USER_NAME":"$USER_NAME" "$HOME/.cache"


# Set theme and icons
sudo -u "$USER_NAME" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $USER_NAME)/bus" gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
sudo -u "$USER_NAME" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $USER_NAME)/bus" gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
sudo -u "$USER_NAME" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $USER_NAME)/bus" gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Force hyprland reload
sudo -u "$USER_NAME" -H HYPRLAND_INSTANCE_SIGNATURE="$HYPRLAND_INSTANCE_SIGNATURE" hyprctl reload
sudo -u "$USER_NAME" -H HYPRLAND_INSTANCE_SIGNATURE="$HYPRLAND_INSTANCE_SIGNATURE" hyprctl dispatch exec "killall waybar; waybar"


# Ask for neovim
echo -n "Do you want to install/replace your config with OrionVim? [y/N] "
read -r confirm < /dev/tty
confirm="${confirm,,}"

if [[ "$confirm" == "y" ]]; then
    rm -rf "$CONFIG/nvim" > /dev/null 2>&1
    rm -rf "$HOME/.local/share/nvim" > /dev/null 2>&1 

    if [ "${#NEOVIM_PACKAGES[@]}" -gt 0 ]; then
        echo "Installing Neovim dependencies..."
        install_pkg "pacman" "${NEOVIM_PACKAGES[@]}"
    fi

    if execute_silent "Cloning OrionVim repository" sudo -u "$USER_NAME" git clone "$NEOVIM_REPO" "$CONFIG/nvim"; then
        rm -rf "$CONFIG/nvim/.git" > /dev/null 2>&1
        
        chown -R "$USER_NAME":"$USER_NAME" "$CONFIG/nvim" > /dev/null 2>&1
    else
        echo "Error: OrionVim cloning failed. Check your internet connection or repository URL."
    fi
fi


# Ask for theme changer
echo -n "Do you want to keep the theme changer? [Y/n] "
read -r confirm_theme < /dev/tty
confirm_theme="${confirm_theme,,}"

if [[ "$confirm_theme" == "n" ]]; then
### === START CLEANUP.SH === ###
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
rm -f "$CONFIG/swaync/template.css"
rm -f "$CONFIG/oh-my-posh/themes/template.omp.json"


# Change hyprland border
TARGET_FILE="$CONFIG/hypr/hyprland.conf"
SEARCH_LINE='source = ~/.config/hypr/dynamic-border.conf'
SOURCE_FILE="$HOME/.config/hypr/dynamic-border.conf"
CONTENT=$(<"$SOURCE_FILE")

awk -v search="$SEARCH_LINE" -v replacement="$CONTENT" '
    $0 == search { print replacement; next }
    { print }
' "$TARGET_FILE" > "${TARGET_FILE}.tmp" && mv "${TARGET_FILE}.tmp" "$TARGET_FILE"

sed -i "\|bind = $mainMod SHIFT, T, exec, sh $HOME/.config/scripts/theme_chooser.sh # Change theme based on wallpaper|d" "$TARGET_FILE"


# Remove pacman dependencies
for pkg in "${THEME_CHANGER_DEPENDENCIES_PACMAN[@]}"; do
    sudo pacman -Rs --noconfirm "$pkg"
done


# Remove yay dependencies
for pkg in "${THEME_CHANGER_DEPENDENCIES_YAY[@]}"; do
    sudo -u "$USER_NAME" -H yay -R --noconfirm "$pkg"
done


# Removing useless scripts
rm -rf "$THEME_CHANGER_SCRIPTS"


# Removing sudoers rule
if [ -f "$SUDOERS_FILE" ]; then
    rm -f "$SUDOERS_FILE"
fi
### === END CLEANUP.SH === ###
fi

# Enable and start TLP
echo -n "Do you want to enable TLP (power management)? [y/N] "
read -r confirm_tlp < /dev/tty
confirm_tlp="${confirm_tlp,,}"

if [[ "$confirm_tlp" == "y" ]]; then
    systemctl enable tlp.service
    systemctl start tlp.service
fi

# Enable and start UFW
echo -n "Do you want to enable UFW firewall? [Y/n] "
read -r confirm_ufw < /dev/tty
confirm_ufw="${confirm_ufw,,}"

if [[ "$confirm_ufw" == "y" || -z "$confirm_ufw" ]]; then
    echo "Enabling and configuring UFW..."
    systemctl enable ufw.service
    systemctl start ufw.service
    ufw default deny incoming
    ufw default allow outgoing
    ufw --force enable
fi

# Delete useless resources
sudo rm -rf "$CONFIG/$INSTALL_SCRIPTS"
sudo rm -rf "$CONFIG/scripts/update-configs.sh"
sudo rm "$CONFIG/install.sh"
sudo rm "$CONFIG/README.md"
sudo rm -rf "$HOME/yay"

# Delete useless hyprland settings
sed -i "\|exec-once = ~/.config/scripts/update_configs.sh|d" "$TARGET_FILE"

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

echo "We suggest to close this terminal or run 'source ~/.bashrc' to complete the installation"
echo "Enjoy your new setup!"
