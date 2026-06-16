#!/bin/bash

# Define packages to install
packages=(
  plasma
  kdebase-runtime
  kdeplasma-addons
  networkmanager
  konsole
  dolphin
  ark
)

# Initialize variable
installed=false

cd "$(dirname "$0")" || exit
# Check and install missing packages
for pkg in "${packages[@]}"; do
  # Check if the package is installed
  if ! ./helpers/check_package_installed.sh "$pkg"; then
    # Install the package if it's not already installed
    sudo pacman -S --noconfirm "$pkg"
    installed=true
  fi
done

sleep 10

# Enable and start NetworkManager if not already running
if systemctl is-active --quiet NetworkManager.service; then
  echo "NetworkManager is already running."
else
  echo "Enabling and starting NetworkManager..."
  sudo systemctl enable NetworkManager.service
  sudo systemctl start NetworkManager.service
fi

# Get the current username
current_user=$(whoami)

# Add the current user to the 'wheel' group if not already a member
if id -nG "$current_user" | grep -qw "wheel"; then
  echo "User '$current_user' is already in the wheel group."
else
  echo "Adding user '$current_user' to the wheel group..."
  sudo usermod -aG wheel "$current_user"
fi

# Create a snapshot with Snapper if installation was performed
if [ "$installed" = true ]; then
  echo "Creating a snapshot with Snapper..."
  sudo snapper create --description "backup: post-install KDE Plasma"
fi
