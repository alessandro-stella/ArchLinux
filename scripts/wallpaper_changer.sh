#!/bin/bash

# === PARAMETERS ===
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
DEST_PATH="/usr/share/sddm/themes/sdt/wallpaper.png"
TMP_PATH="/tmp/sddm_wallpaper_tmp.png"
BLUR_LEVEL="0x12"
CONFIG_WALLPAPER_DIR="$HOME/.config/wallpaper"
HYPRPAPER_PATH="$CONFIG_WALLPAPER_DIR/currentWallpaper.png"
BLURRED_SAVE_PATH="$CONFIG_WALLPAPER_DIR/blurredWallpaper.png"
OLD_BLURRED_SAVE_PATH="$CONFIG_WALLPAPER_DIR/oldBlurredWallpaper.png"

# === CHECK DEPENDENCIES ===
if ! command -v magick &>/dev/null; then
  echo "Error: 'magick' (ImageMagick) is not installed."
  exit 1
fi

if [ ! -d "$WALLPAPER_DIR" ]; then
  echo "Error: wallpaper directory not found: $WALLPAPER_DIR"
  exit 1
fi

if [ ! -d "$CONFIG_WALLPAPER_DIR" ]; then
  echo "Creating directory for wallpaper config: $CONFIG_WALLPAPER_DIR"
  mkdir -p "$CONFIG_WALLPAPER_DIR"
fi

# === BACKUP OLD BLURRED WALLPAPER ===
if [ -f "$BLURRED_SAVE_PATH" ]; then
  echo "Backing up existing blurred wallpaper to oldBlurredWallpaper.png..."
  cp "$BLURRED_SAVE_PATH" "$OLD_BLURRED_SAVE_PATH"
fi

# === SELECT RANDOM IMAGE ===
SELECTED_IMAGE=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) | shuf -n 1)

if [ -z "$SELECTED_IMAGE" ]; then
  echo "Error: no image files found in $WALLPAPER_DIR"
  exit 1
fi

echo "Selected wallpaper: $SELECTED_IMAGE"

# === CREATE TEMPORARY BLURRED IMAGE ===
echo "Generating blurred wallpaper..."
magick "$SELECTED_IMAGE" -resize 1920x1080^ -gravity center -extent 1920x1080 -blur "$BLUR_LEVEL" "$TMP_PATH"

# === SAVE BLURRED IMAGE IN ~/.config/wallpaper ===
echo "Saving blurred wallpaper to $BLURRED_SAVE_PATH..."
cp "$TMP_PATH" "$BLURRED_SAVE_PATH"

# === COPY TO SET CURRENT WALLPEPER ===
echo "Copying original wallpaper to $HYPRPAPER_PATH..."
cp "$SELECTED_IMAGE" "$HYPRPAPER_PATH"

# === COPY TO SDDM THEME (requires sudo) ===
echo "Copying blurred wallpaper to $DEST_PATH (requires sudo)..."
if sudo cp "$BLURRED_SAVE_PATH" "$DEST_PATH"; then
  echo "Copy successful."
else
  echo "Error: failed to copy blurred wallpaper to $DEST_PATH"
  exit 1
fi

# === CLEANUP ===
rm -f "$TMP_PATH"

echo "Done: new blurred wallpaper saved, old blurred wallpaper backed up, and applied to SDDM."
