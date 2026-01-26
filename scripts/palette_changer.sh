#!/bin/bash

WALLPAPER="$HOME/.config/wallpaper/current_wallpaper.png"
WAL_COLORS_JSON="$HOME/.cache/wallust/colors.json"
HYPR_CONF="$HOME/.config/hypr/dynamic-border.conf"
TEMPLATE="$HOME/.config/wlogout/template.css"
OUTPUT="$HOME/.config/wlogout/style.css"
OPACITY="ee"

# Filter parameters
BRIGHT_MIN=30
BRIGHT_MAX=230

# Check dependencies
for cmd in wallust jq awk sed hyprctl bc; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Error: $cmd is not installed."; exit 1; }
done

# Generate palette
rm -rf ~/.cache/wallust
wallust run "$WALLPAPER" || { echo "Error: wallust failed."; exit 1; }

# Utility functions
hex_to_rgb() {
  local hex="${1#"#"}"
  echo "$((16#${hex:0:2})) $((16#${hex:2:2})) $((16#${hex:4:2}))"
}

dominant_channel() {
  local r=$1; local g=$2; local b=$3
  if (( r >= g && r >= b )); then echo "R"
  elif (( g >= r && g >= b )); then echo "G"
  else echo "B"; fi
}

hex_to_brightness() {
  local hex="${1#"#"}"
  local r=$((16#${hex:0:2}))
  local g=$((16#${hex:2:2}))
  local b=$((16#${hex:4:2}))
  echo "$(awk "BEGIN {print 0.299*$r + 0.587*$g + 0.114*$b}")"
}

print_color_box() {
  local hex="${1//#/}"
  local r=$((16#${hex:0:2}))
  local g=$((16#${hex:2:2}))
  local b=$((16#${hex:4:2}))
  local label="$2"
  printf "%s: #%s " "$label" "$hex"
  printf "\e[48;2;%d;%d;%dm  \e[0m\n" "$r" "$g" "$b"
}

# Extract colors from JSON
COLORS_ARRAY=($(jq -r '.[]' "$WAL_COLORS_JSON"))
declare -A color_info

for hex in "${COLORS_ARRAY[@]}"; do
  [[ "$hex" =~ ^#[0-9a-fA-F]{6}$ ]] || continue
  read r g b <<< "$(hex_to_rgb "$hex")"
  brightness=$(hex_to_brightness "$hex")
  dominant=$(dominant_channel "$r" "$g" "$b")

  # Filter: discard colors too dark or too bright
  if (( $(echo "$brightness < $BRIGHT_MIN || $brightness > $BRIGHT_MAX" | bc -l) )); then
    continue
  fi

  key="${hex}"
  color_info["$key"]="$brightness|$dominant"
done

# Check if there are enough colors
if (( ${#color_info[@]} < 2 )); then
  echo "Error: Palette too limited after brightness filtering."
  exit 1
fi

# Sort by descending brightness
sorted_colors=($(for c in "${!color_info[@]}"; do
  echo "$c ${color_info[$c]%%|*}"
done | sort -k2 -nr | awk '{print $1}'))

# First color
color1="${sorted_colors[0]}"
brightness1="${color_info[$color1]%%|*}"
dominant1="${color_info[$color1]##*|}"

# Second color: with different dominant channel and minimum distance
color2=""
min_dist=9999

read r1 g1 b1 <<< "$(hex_to_rgb "$color1")"

for c in "${sorted_colors[@]:1}"; do
  dominant2="${color_info[$c]##*|}"
  [[ "$dominant2" == "$dominant1" ]] && continue

  read r2 g2 b2 <<< "$(hex_to_rgb "$c")"
  dist=$(awk "BEGIN {
    dx = $r1 - $r2; dy = $g1 - $g2; dz = $b1 - $b2;
    print sqrt(dx*dx + dy*dy + dz*dz)
  }")

  if (( $(echo "$dist < $min_dist" | bc -l) )); then
    min_dist=$dist
    color2="$c"
  fi
done

# Fallback
if [ -z "$color2" ]; then
  echo "Warning: No color with different dominant channel found. Using second brightest."
  color2="${sorted_colors[1]}"
  dominant2="${color_info[$color2]##*|}"
fi

# --- OUTPUT TO SCREEN ---
echo -e "\n🎨 Selected colors:"
print_color_box "$color1" "Color1 (Dominant $dominant1)"
print_color_box "$color2" "Color2 (Dominant $dominant2)"
echo ""

# --- WLOGOUT ---
hex_rgb="${color2//#/}"
r=$((16#${hex_rgb:0:2}))
g=$((16#${hex_rgb:2:2}))
b=$((16#${hex_rgb:4:2}))
rgb_string="$r, $g, $b"
sed "s/__BUTTON_ACCENT__/${rgb_string}/g" "$TEMPLATE" > "$OUTPUT"
echo "✅ Wlogout CSS updated with RGB color: $rgb_string"

# --- WAYBAR ---
"$(dirname "$0")/waybar_changer.sh" "$color1"

# --- OH-MY-POSH ---
"$(dirname "$0")/oh_my_posh_changer.sh"

# --- HYPRLAND ---
hex_with_opacity() {
  local hex="${1//#/}"
  echo "${hex}${OPACITY}"
}

color1_opacity=$(hex_with_opacity "$color1")
color2_opacity=$(hex_with_opacity "$color2")

conf_content="general {
  col.active_border = rgba(${color1_opacity}) rgba(${color2_opacity}) 45deg
}"

echo "$conf_content" > "$HYPR_CONF"
hyprctl reload
echo "✅ Hyprland: border updated in $HYPR_CONF"
