#!/bin/bash

# Screenshot directory
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

# Output file name
FILENAME="$DIR/$(date +%Y-%m-%d_%H-%M-%S).png"

# Capture frozen region with hyprshot
hyprshot -m region -z -o "$FILENAME" -f "$(date +%Y-%m-%d_%H-%M-%S).png"

# Copy to clipboard
# wl-copy < "$FILENAME"

# Open with swappy for editing
# swappy -f "$FILENAME" --output-file "$FILENAME"
