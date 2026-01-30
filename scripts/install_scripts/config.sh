#!/usr/bin/env bash

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
  "waybar"
  "swaync"
  "libnotify"
  "unzip"
  "github-cli"
  "hyprshot"
  "loupe"
  "qt5-graphicaleffects"
  "qt6-5compat"
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
  "brightnessctl"
  "blueman"
  "nautilus"
  "evince"
  "libreoffice-still"
  "libreoffice-still-it"
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
