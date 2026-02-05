#!/usr/bin/env bash

# Get the directory where this script is located
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# Source file paths (now relative to the script's actual location)
CONFIG_FILE="$SCRIPT_DIR/config.sh"
CLEANUP_FILE="$SCRIPT_DIR/cleanup.sh"
BODY_FILE="$SCRIPT_DIR/install_body.sh"

# Final destination path
DEST_DIR="$HOME/.config"
OUTPUT_FILE="$DEST_DIR/install.sh"

echo
echo "Generating install.sh..."

# 1. Start with the shebang and a generation notice
echo "#!/usr/bin/env bash" > "$OUTPUT_FILE"
echo "# === UNIFIED SCRIPT (AUTO-GENERATED) ===" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 2. Read install_body.sh line by line and replace "source" commands
while IFS= read -r line; do
    # Check for config.sh sourcing
    if [[ "$line" =~ source[[:space:]]+\./config\.sh ]]; then
        echo "   -> Injecting config.sh..."
        echo "### === START CONFIG.SH === ###" >> "$OUTPUT_FILE"
        grep -v '^#!' "$CONFIG_FILE" >> "$OUTPUT_FILE"
        echo "### === END CONFIG.SH === ###" >> "$OUTPUT_FILE"
        
    # Check for cleanup.sh sourcing
    elif [[ "$line" =~ source[[:space:]]+\"cleanup\.sh\" ]]; then
        echo "   -> Injecting cleanup.sh..."
        echo "### === START CLEANUP.SH === ###" >> "$OUTPUT_FILE"
        grep -v '^#!' "$CLEANUP_FILE" >> "$OUTPUT_FILE"
        echo "### === END CLEANUP.SH === ###" >> "$OUTPUT_FILE"
        
    else
        # Keep standard lines, skipping the original shebang of install_body
        if [[ ! "$line" =~ ^#! ]]; then
            echo "$line" >> "$OUTPUT_FILE"
        fi
    fi
done < "$BODY_FILE"

# 3. Apply execution permissions
chmod +x "$OUTPUT_FILE"

echo
echo "Success! The script has been created and moved to: $OUTPUT_FILE"
