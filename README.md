[sddm]: https://github.com/user-attachments/assets/d752e47d-3af8-4949-a48f-b1fa697abcb1
[wlogout]: https://github.com/user-attachments/assets/a62059bd-0f3e-4463-b050-03b97ffd153e
[shell]: https://github.com/user-attachments/assets/f81e980f-ee29-49d7-b496-395b90dd3425
[theme_changer]: https://github.com/user-attachments/assets/ff9fb61f-6d26-4b36-bf20-965440a01e6
[showcase]: https://github.com/user-attachments/assets/732fd1c3-df08-4414-b5b7-d441e79b26a9

# Dotfiles for custom Arch Linux + Hyprland config

## Core concepts
This configuration prioritizes simplicity and usability for developers, without sacrificing customizability and aesthetic.

## Configuration Overview
<a href="https://github.com/user-attachments/assets/d752e47d-3af8-4949-a48f-b1fa697abcb1">
  <img src="https://github.com/user-attachments/assets/d752e47d-3af8-4949-a48f-b1fa697abcb1" alt="SDDM Greeter" width="150">
</a>
<a href="https://github.com/user-attachments/assets/a62059bd-0f3e-4463-b050-03b97ffd153e">
  <img src="https://github.com/user-attachments/assets/a62059bd-0f3e-4463-b050-03b97ffd153e" alt="wlogout" width="150">
</a>
<a href="https://github.com/user-attachments/assets/f81e980f-ee29-49d7-b496-395b90dd3425">
  <img src="https://github.com/user-attachments/assets/f81e980f-ee29-49d7-b496-395b90dd3425" alt="Shell" width="150">
</a>
<a href="https://github.com/user-attachments/assets/ff9fb61f-6d26-4b36-bf20-965440a01e6">
  <img src="https://github.com/user-attachments/assets/ff9fb61f-6d26-4b36-bf20-965440a01e6" alt="Theme changer" width="150">
</a>
<a href="https://github.com/user-attachments/assets/732fd1c3-df08-4414-b5b7-d441e79b26a9">
  <img src="https://github.com/user-attachments/assets/732fd1c3-df08-4414-b5b7-d441e79b26a9" alt="General showcase" width="150">
</a>




### Shell and Terminal
- Main shell: bash
- Prompt: oh-my-posh
- Package manager: pacman and yay
- Emulator: Kitty
- Font: JetBrains Mono Nerd
- System info: btop, fastfetch

### User Experience and Aesthetic
- Status bar: waybar
- File manager: nautilus
- GTK / QT theme: adw-gtk3
- Icon set: Adwaita
- Login greeter: SDDM
- Lock: swaylock and wlogout
- Multimedia and audio: pamixer, pavucontrol, blueman, brightnessctl
- Network and safety: network-manager-applet, ufw, tlp
- Main browser: Brave

## Custom scripts
On each login some scripts are launched to enhanche the user experience. All of these can be found in "*~/.config/scripts*"
- **clean_java_workspaces.sh**: when working with java a folder gets created to cache compiled workspaces. This script deletes all those workspaces older than 3 months to avoid excessive memory usage.
- **clean_screenshots.sh**: all screenshots taken during current session are saved in "*~/Pictures/Screenshots*". On each login the content of this folder gets deleted to avoid keeping too many useless images.

## Theme changer
![alt_text][theme_changer]

## Additional features
Some websites frequently used, such as ChatGpt, Google Gemini and Microsoft Teams, can be quickly launched with their specific shortcut. These concept can be further expanded by adding all frequently used apps. Some suggestions might be Whatsapp Web or Discord.
At the end of "*~/.config/hypr/hyprland.conf*" those shortcuts can be changed, or new ones can be added by following the same pattern.

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
