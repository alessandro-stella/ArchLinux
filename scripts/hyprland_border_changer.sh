#!/bin/bash

WALLPAPER="$HOME/.config/wallpaper/oldBlurredWallpaper.png"
WAL_COLORS_JSON="$HOME/.cache/wal/colors.json"
HYPR_CONF="$HOME/.config/hypr/dynamic-border.conf"
TEMPLATE="$HOME/.config/wlogout/template.css"
OUTPUT="$HOME/.config/wlogout/style.css"
OPACITY="ee"
BRIGHTNESS_DIFF_THRESHOLD=15

# Check dependencies
for cmd in wal jq awk bc sed hyprctl; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Error: $cmd is not installed."; exit 1; }
done

# Generate palette JSON from wallpaper (do not apply colors)
rm -rf ~/.cache/wal
wal -i "$WALLPAPER" -q -n --backend json || { echo "Error: wal failed."; exit 1; }

# Function to calculate brightness from hex color using ITU-R BT.601 formula
hex_to_brightness() {
  local hex="${1#"#"}"
  local r=$((16#${hex:0:2}))
  local g=$((16#${hex:2:2}))
  local b=$((16#${hex:4:2}))
  local brightness
  brightness=$(awk "BEGIN {print 0.299*$r + 0.587*$g + 0.114*$b}")
  echo "$brightness"
}

# Extract colors from wal JSON
colors=$(jq -r '.colors | to_entries[] | "\(.key) \(.value)"' "$WAL_COLORS_JSON")

declare -A color_brightness

while read -r key hexcolor; do
  brightness=$(hex_to_brightness "$hexcolor")
  color_brightness[$hexcolor]=$brightness
done <<< "$colors"

# Sort colors by brightness descending
sorted_colors=($(for c in "${!color_brightness[@]}"; do echo "$c ${color_brightness[$c]}"; done | sort -k2 -nr | awk '{print $1}'))

color1="${sorted_colors[0]}"
brightness1=${color_brightness[$color1]}

color2=""
for c in "${sorted_colors[@]:1}"; do
  diff=$(awk -v b1="$brightness1" -v b2="${color_brightness[$c]}" 'BEGIN {print (b1 > b2) ? b1 - b2 : b2 - b1}')
  if (( $(echo "$diff >= $BRIGHTNESS_DIFF_THRESHOLD" | bc -l) )); then
    color2="$c"
    break
  fi
done

if [ -z "$color2" ]; then
  echo "Warning: Could not find a second color sufficiently different in brightness."
  color2="${sorted_colors[1]}"
fi

# Remove '#' and opacity, keep only RRGGBB (6 chars)
hex_rgb="${color2//#/}"
hex_rgb="${hex_rgb:0:6}"

# Extract decimal R, G, B values
r=$((16#${hex_rgb:0:2}))
g=$((16#${hex_rgb:2:2}))
b=$((16#${hex_rgb:4:2}))

# Create replacement string "R, G, B"
rgb_string="$r, $g, $b"

# Replace __BUTTON_ACCENT__ in template CSS with rgb_string
sed "s/__BUTTON_ACCENT__/${rgb_string}/g" "$TEMPLATE" > "$OUTPUT"

echo "Wlogout CSS updated with RGB color: $rgb_string"
