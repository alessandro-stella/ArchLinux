#!/bin/bash

REPOS=(
  "$HOME/.config"
  "$HOME/.config/nvim"
)

for REPO in "${REPOS[@]}"; do
  if [ -d "$REPO/.git" ]; then
    cd "$REPO" || continue
    OUTPUT=$(git pull 2>&1)
    STATUS=$?

    REPO_NAME=$(basename "$REPO")

    if [ $STATUS -eq 0 ]; then
      notify-send "[$REPO_NAME] Pull Success" "$OUTPUT"
    else
      notify-send "[$REPO_NAME] Pull Failed" "$OUTPUT"
    fi

  else
    notify-send "[$REPO] is not a valid git repository"
  fi
done
