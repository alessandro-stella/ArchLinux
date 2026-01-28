#!/usr/bin/env bash

PACMAN_PACKAGES=(
  "git"
  "base-devel"
  "btop"
  "thunar"
  "swww"
  "waybar"
  "swaync"
  "unzip"
  "realpath"
  "dirname"
  "git-lfs"
  "github-cli"
  "hyprshot"
  "loupe"
  "qt5-quickcontrols"
  "qt5-quickcontrols2"
  "qt6-wayland"
  "rsync"
  "tlp"
  "ufw"
  "yazi")

YAY_PACKAGES=("")

declare -A EXTERNAL_PACKAGES = (
  ["oh-my-posh"]="https://ohmyposh.dev/install.sh"
)
