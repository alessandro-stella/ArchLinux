#!/bin/bash

WAL_COLORS_JSON="$HOME/.cache/wallust/colors-kitty.conf"
TEMPLATE_CSS="$HOME/.config/waybar/template.css"
OUTPUT_CSS="$HOME/.config/waybar/style.css"

echo
echo "Changing waybar colors..."

for cmd in jq sed; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Error: $cmd is not installed."; exit 1; }
done

BG_HEX=$(grep -m1 'background' $WAL_COLORS_JSON | grep -oE '#[0-9a-fA-F]{6}') || { echo "Error reading background color from wal."; exit 1; }
LOGO_HEX=${1:-"#89b4fa"}
ALPHA=0.8

convertToRgba() {
    local hex="${1#\#}"
    local alpha="${2:-1.0}"
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    printf "rgba(%d, %d, %d, %.2f)" "$r" "$g" "$b" "$alpha"
}

sed -e "s/__BACKGROUND_COLOR__/$(convertToRgba "$BG_HEX" "$ALPHA")/g" \
    -e "s/__LOGO_COLOR__/$(convertToRgba "$LOGO_HEX" 1.0)/g" \
    "$TEMPLATE_CSS" > "$OUTPUT_CSS"

# === RESTARTING WAYBAR ===
pkill -x waybar
waybar &

echo "Waybar updated!"
echo "Background color: $BG_HEX"
echo "Arch logo color: $LOGO_HEX"
echo
