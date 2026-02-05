#!/bin/bash

# === PARAMETERS ===
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
DEST_PATH="/usr/share/sddm/themes/sdt/wallpaper.png"
TMP_PATH="/tmp/sddm_wallpaper_tmp.png"
BLUR_LEVEL="0x12"
CONFIG_WALLPAPER_DIR="$HOME/.config/wallpaper"
# Updated name for clarity, acts as the reference for swww
CURRENT_WALLPAPER="$CONFIG_WALLPAPER_DIR/current_wallpaper.png"
BLURRED_SAVE_PATH="$CONFIG_WALLPAPER_DIR/blurred_wallpaper.png"

# === CHECK DEPENDENCIES ===
for cmd in magick swww bc; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is not installed."
    exit 1
  fi
done

if [ ! -d "$CONFIG_WALLPAPER_DIR" ]; then
  mkdir -p "$CONFIG_WALLPAPER_DIR"
fi

# === SELECT IMAGE ===
# If an argument is provided, use it; otherwise, pick a random image
SELECTED_IMAGE=$([[ -n "${1:-}" ]] && echo "$1" || find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)

if [ -z "$SELECTED_IMAGE" ] || [ ! -f "$SELECTED_IMAGE" ]; then
  echo "Error: image file not found at '$SELECTED_IMAGE'"
  exit 1
fi

echo "Selected wallpaper: $SELECTED_IMAGE"

# Update symbolic link or copy file to maintain a fixed reference
cp "$SELECTED_IMAGE" "$CURRENT_WALLPAPER"

# === APPLY WITH SWWW ===
# Check if the daemon is active, start it if not
if ! swww query &>/dev/null; then
    echo "Starting swww-daemon..."
    swww-daemon &
    sleep 0.5
fi

# Generate random coordinates for the "grow" transition effect
RAND_X=$(echo "scale=2; $((RANDOM % 101)) / 100" | bc)
RAND_Y=$(echo "scale=2; $((RANDOM % 101)) / 100" | bc)

echo "Transition starting at X:$RAND_X Y:$RAND_Y"

# Apply wallpaper with optimized transition
swww img "$CURRENT_WALLPAPER" \
    --transition-type grow \
    --transition-pos "$RAND_X,$RAND_Y" \
    --transition-step 90 \
    --transition-fps 60 \
    --transition-duration 1.5

# === UPDATE COLORS (Wal/Pywal/Palette) ===
PALETTE_SCRIPT="$(dirname "$0")/palette_changer.sh"
if [ -f "$PALETTE_SCRIPT" ]; then
    echo "Updating system color palette..."
    "$PALETTE_SCRIPT"
fi

# === SDDM BLURRED WALLPAPER ===
# Generate the blurred version in the background to avoid blocking the script
echo "Generating blurred wallpaper for SDDM..."
(
    magick "$SELECTED_IMAGE" -resize 1920x1080^ -gravity center -extent 1920x1080 -blur "$BLUR_LEVEL" "$TMP_PATH"
    cp "$TMP_PATH" "$BLURRED_SAVE_PATH"
    
    # Attempt to copy to SDDM without blocking if sudo fails or requires password
    if sudo -n cp "$BLURRED_SAVE_PATH" "$DEST_PATH" 2>/dev/null; then
        echo "SDDM wallpaper successfully updated."
    else
        echo "SDDM update skipped (requires sudo or password-less sudo rule)."
    fi
    rm -f "$TMP_PATH"
) &

# === NOTIFY ===
notify-send -i "$SELECTED_IMAGE" -u low "Wallpaper Changed" "Transition: Grow from $RAND_X, $RAND_Y"

echo "Wallpaper update process completed!"
