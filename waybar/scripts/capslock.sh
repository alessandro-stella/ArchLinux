#!/bin/bash

caps_state=$(swaymsg -t get_inputs | jq -r '.[] select(.type=="keyboard") | .xkb_active_layout_caps_lock')

if [[ "$caps_state" == "1" ]]; then
  echo "CAPS ON"
else
  echo ""
fi
