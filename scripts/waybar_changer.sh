#!/bin/bash

WAL_COLORS_JSON="$HOME/.cache/wal/colors.json"
TEMPLATE_CSS="$HOME/.config/waybar/template.css"
OUTPUT_CSS="$HOME/.config/waybar/style.css"

for cmd in jq sed; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Error: $cmd is not installed."; exit 1; }
done

BG_HEX=$(jq -r '.special.background' "$WAL_COLORS_JSON") || { echo "Error reading background color from wal."; exit 1; }

sed "s/__BACKGROUND_COLOR__/$BG_HEX/g" "$TEMPLATE_CSS" > "$OUTPUT_CSS"

echo "CSS file updated with kitty background color from wal: $BG_HEX"
