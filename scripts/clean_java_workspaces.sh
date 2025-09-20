#!/bin/bash

WORKSPACE="$HOME/.workspace-java"

if [ -d "$WORKSPACE" ]; then
    rm -rf "$WORKSPACE"
fi

mkdir -p "$WORKSPACE"
