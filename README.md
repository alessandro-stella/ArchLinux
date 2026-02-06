[sddm]: https://private-user-images.githubusercontent.com/90006843/546329524-d752e47d-3af8-4949-a48f-b1fa697abcb1.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NzAzOTgzNjksIm5iZiI6MTc3MDM5ODA2OSwicGF0aCI6Ii85MDAwNjg0My81NDYzMjk1MjQtZDc1MmU0N2QtM2FmOC00OTQ5LWE0OGYtYjFmYTY5N2FiY2IxLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNjAyMDYlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjYwMjA2VDE3MTQyOVomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWI3MmU5ZDliMTg1YmMzY2MyOTc5MjIxMGFmMGViZTYzMjVkNGVjZWUxZjU2MzQ0MTYxZWI3YzAxNTg2OGIxYmUmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.jWFuuhwmItKmiX8_avUWnc4-PLtAi_7SvCyvYfBHjUA "SDDM Greeter"

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
