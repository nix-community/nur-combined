#!/bin/bash

# Define the path to the pacman configuration file
PACMAN_CONF="/etc/pacman.conf"

# Get the current date in YYYY-MM-DD format
DATE=$(date +%F)

# Check if the multilib section is already enabled
if grep -q '^\[multilib\]' "$PACMAN_CONF" && grep -q '^\s*Include = /etc/pacman.d/mirrorlist' "$PACMAN_CONF"; then
  echo "The multilib repository is already enabled."
else
  # Backup the original configuration file with the date in the filename
  sudo cp "$PACMAN_CONF" "$PACMAN_CONF.bak.$DATE"

  # Enable the multilib repository
  echo "Enabling the multilib repository..."

  # Uncomment only the [multilib] section and its corresponding Include line
  sudo sed -i '/#\[multilib\]/,/#Include = \/etc\/pacman\.d\/mirrorlist/ s/^#//' "$PACMAN_CONF"

  # Update the package database
  sudo pacman -Sy
fi
