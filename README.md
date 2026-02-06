[sddm]: https://github.com/user-attachments/assets/d752e47d-3af8-4949-a48f-b1fa697abcb1 "SDDM Greeter"

# Dotfiles for custom Arch Linux + Hyprland config

## Core concepts
This configuration prioritizes simplicity and usability for developers, without sacrificing customizability and aesthetic.

## System components

## Installation

One liner
```bash
curl -fsSL https://raw.githubusercontent.com/alessandro-stella/dotfiles/master/install.sh | \
sudo HYPRLAND_INSTANCE_SIGNATURE=$HYPRLAND_INSTANCE_SIGNATURE bash
```

Manual
```bash
git clone https://github.com/<username>/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

![alt text][sddm]
