#!/bin/bash

# === PARAMETERS ===
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
THUMB_DIR="$WALLPAPER_DIR/thumbnails"
THUMB_SIZE="320x180"
QUALITY=80

# === DIRECTORY CHECK ===
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Error: Directory $WALLPAPER_DIR does not exist."
    exit 1
fi

mkdir -p "$THUMB_DIR"

# === COLLECT WALLPAPERS ===
mapfile -t WALLPAPERS < <(
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \)
)

echo
echo "Wallpapers found: ${#WALLPAPERS[@]}"
echo "Scanning thumbnails..."

# === BUILD WALLPAPER NAME SET ===
declare -A WALL_NAMES
for FILE in "${WALLPAPERS[@]}"; do
    NAME="$(basename "$FILE")"
    WALL_NAMES["${NAME%.*}"]=1
done

# === CLEANUP ORPHAN THUMBNAILS ===
REMOVED=0

mapfile -t THUMBS < <(
    find "$THUMB_DIR" -maxdepth 1 -type f -iname "*.png"
)

for THUMB in "${THUMBS[@]}"; do
    NAME="$(basename "$THUMB")"
    BASE="${NAME%.png}"

    if [ -z "${WALL_NAMES[$BASE]}" ]; then
        rm -f "$THUMB"
        REMOVED=$((REMOVED + 1))
    fi
done

echo "Orphan thumbnails removed: $REMOVED"

# === CHECK FOR MISSING THUMBNAILS ===
MISSING=()

for FILE in "${WALLPAPERS[@]}"; do
    NAME="$(basename "$FILE")"
    BASE="${NAME%.*}"
    THUMB_FILE="$THUMB_DIR/$BASE.png"

    if [ ! -f "$THUMB_FILE" ]; then
        MISSING+=("$FILE")
    fi
done

TOTAL_MISSING=${#MISSING[@]}

if [ "$TOTAL_MISSING" -eq 0 ]; then
    echo "All thumbnails are present."
    exit 0
fi

echo
echo "Missing thumbnails: $TOTAL_MISSING"
echo "Generating thumbnails..."

# === GENERATION PHASE ===
CURRENT=0

for FILE in "${MISSING[@]}"; do
    mogrify -path "$THUMB_DIR" \
            -thumbnail "$THUMB_SIZE^" \
            -gravity center \
            -extent "$THUMB_SIZE" \
            -quality "$QUALITY" \
            -format png \
            "$FILE"

    CURRENT=$((CURRENT + 1))
    PERCENT=$((CURRENT * 100 / TOTAL_MISSING))
    printf "\rProgress: %3d%% (%d/%d)" "$PERCENT" "$CURRENT" "$TOTAL_MISSING"
done

echo
echo "Done! Thumbnails created: $TOTAL_MISSING"
