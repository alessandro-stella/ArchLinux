#!/bin/bash

WAL_COLORS_JSON="$HOME/.cache/wallust/colors-kitty.conf"
TEMPLATE_CSS="$HOME/.config/swaync/template.css"
OUTPUT_CSS="$HOME/.config/swaync/style.css"

echo
echo "Updating SwayNC styles..."

BG_HEX=$(grep -m1 'background' "$WAL_COLORS_JSON" | grep -oE '#[0-9a-fA-F]{6}') || { echo "Error reading background color."; exit 1; }

BORDER_HEX=${1:-"595959"}
[[ $BORDER_HEX != \#* ]] && BORDER_HEX="#$BORDER_HEX"

ALPHA=0.85

convertToRgba() {
    local hex="${1#\#}"
    local alpha="${2:-1.0}"
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    printf "rgba(%d, %d, %d, %.2f)" "$r" "$g" "$b" "$alpha"
}

sed -e "s/__BACKGROUND_COLOR__/$(convertToRgba "$BG_HEX" "$ALPHA")/g" \
    -e "s/__BORDER_COLOR__/$BORDER_HEX/g" \
    "$TEMPLATE_CSS" > "$OUTPUT_CSS"

swaync-client -R
swaync-client -rs

echo "SwayNC updated!"
echo "Background (RGBA): $(convertToRgba "$BG_HEX" "$ALPHA")"
echo "Border (Hex): $BORDER_HEX"
echo
