#!/bin/bash

# === PARAMETERS ===
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
THUMB_DIR="$WALLPAPER_DIR/thumbnails"
THUMB_SIZE="320x180" # Dimensione ideale per le icone di Rofi
QUALITY=80            # Qualità JPEG/PNG per ridurre il peso dei file

# === CHECK DIRECTORY ===
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Errore: La cartella $WALLPAPER_DIR non esiste."
    exit 1
fi

if [ ! -d "$THUMB_DIR" ]; then
    echo "Cartella thumbnails non trovata. Creazione in corso..."
    mkdir -p "$THUMB_DIR"
fi

# === SYNC CHECK ===
# Conta i file escludendo la cartella thumbnails stessa
COUNT_WALLPAPERS=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | wc -l)
COUNT_THUMBS=$(find "$THUMB_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | wc -l)

echo "Sfondi trovati: $COUNT_WALLPAPERS"
echo "Miniature trovate: $COUNT_THUMBS"

if [ "$COUNT_WALLPAPERS" -eq "$COUNT_THUMBS" ]; then
    echo "Le cartelle sono sincronizzate. Nulla da fare."
    exit 0
fi

echo "Sincronizzazione necessaria. Generazione miniature in corso..."

# === GENERATION ===
# Usiamo 'mogrify' che è più veloce di 'convert' per operazioni di massa
# -path: salva i risultati nella cartella thumbnails
# -thumbnail: ottimizzato per creare anteprime (rimuove profili colore pesanti)
cp "$WALLPAPER_DIR"/*.{jpg,jpeg,png} "$THUMB_DIR/" 2>/dev/null || true

mogrify -path "$THUMB_DIR" \
        -thumbnail "$THUMB_SIZE^" \
        -gravity center \
        -extent "$THUMB_SIZE" \
        -quality "$QUALITY" \
        -format png \
        "$THUMB_DIR"/*.png

# Rimuoviamo eventuali file con estensione doppia (es. .png.jpg) se creati dal format
find "$THUMB_DIR" -type f -name "*.*.*" -delete

echo "Done! Miniature ottimizzate create in $THUMB_DIR"
