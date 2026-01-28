#!/usr/bin/env bash

PACMAN_PACKAGES=("")
YAY_PACKAGES=("")
declare -A EXTERNAL_PACKAGES = (
  ["oh-my-posh"]="curl -s https://ohmyposh.dev/install.sh | bash -s"
)
