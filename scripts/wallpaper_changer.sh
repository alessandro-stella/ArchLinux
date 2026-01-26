#!/bin/bash

# === PARAMETERS ===
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
DEST_PATH="/usr/share/sddm/themes/sdt/wallpaper.png"
TMP_PATH="/tmp/sddm_wallpaper_tmp.png"
BLUR_LEVEL="0x12"
CONFIG_WALLPAPER_DIR="$HOME/.config/wallpaper"
# Cambiato nome per chiarezza, ora è il riferimento per swww
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
# Se riceve un argomento usa quello, altrimenti sceglie a caso
SELECTED_IMAGE=$([[ -n "${1:-}" ]] && echo "$1" || find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)

if [ -z "$SELECTED_IMAGE" ] || [ ! -f "$SELECTED_IMAGE" ]; then
  echo "Error: image file not found at '$SELECTED_IMAGE'"
  exit 1
fi

echo "Selected wallpaper: $SELECTED_IMAGE"

# Aggiorna il link simbolico o copia il file per avere un riferimento fisso
cp "$SELECTED_IMAGE" "$CURRENT_WALLPAPER"

# === APPLY WITH SWWW ===
# Verifica se il demone è attivo, altrimenti lo avvia
if ! swww query &>/dev/null; then
    swww-daemon --format xrgb &
    sleep 0.5
fi

# Genera coordinate casuali per l'effetto "grow"
RAND_X=$(echo "scale=2; $((RANDOM % 101)) / 100" | bc)
RAND_Y=$(echo "scale=2; $((RANDOM % 101)) / 100" | bc)

echo "Transition starting at X:$RAND_X Y:$RAND_Y"

# Applica lo sfondo con transizione ottimizzata
swww img "$CURRENT_WALLPAPER" \
    --transition-type grow \
    --transition-pos "$RAND_X,$RAND_Y" \
    --transition-step 90 \
    --transition-fps 60 \
    --transition-duration 1.5

# === UPDATE COLORS (Wal/Pywal/Palette) ===
PALETTE_SCRIPT="$(dirname "$0")/palette_changer.sh"
if [ -f "$PALETTE_SCRIPT" ]; then
    "$PALETTE_SCRIPT"
fi

# === SDDM BLURRED WALLPAPER ===
# Creiamo la versione sfocata in background per non bloccare lo script
echo "Generating blurred wallpaper for SDDM..."
(
    magick "$SELECTED_IMAGE" -resize 1920x1080^ -gravity center -extent 1920x1080 -blur "$BLUR_LEVEL" "$TMP_PATH"
    cp "$TMP_PATH" "$BLURRED_SAVE_PATH"
    
    # Tentativo di copia in SDDM senza bloccare se sudo fallisce o richiede password
    if sudo -n cp "$BLURRED_SAVE_PATH" "$DEST_PATH" 2>/dev/null; then
        echo "SDDM wallpaper updated."
    else
        echo "SDDM update skipped (requires sudo or password-less sudo)."
    fi
    rm -f "$TMP_PATH"
) &

# === NOTIFY ===
notify-send -i "$SELECTED_IMAGE" -u low "Wallpaper Changed" "Transition: Grow from $RAND_X, $RAND_Y"
