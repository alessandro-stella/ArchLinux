#!/usr/bin/env bash

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
    sudo -R --noconfirm "$pkg"
done


# Remove yay dependencies
for pkg in "${THEME_CHOOSER_DEPENDENCIES_YAY[@]}"; do
    yay -R --noconfirm "$pkg"
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
