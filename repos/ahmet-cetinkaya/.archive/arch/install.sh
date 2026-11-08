#!/bin/bash

# Update the system
echo "Updating the system..."
sudo pacman -Syu --noconfirm

# Array of script filenames
cd "$(dirname "$0")" || exit

scripts=(
  scripts/yay.sh
  scripts/snapper.sh
  scripts/sddm.sh
  scripts/kde.sh
  scripts/enable_multilib.sh
  scripts/nvidia.sh
)

helpers=(
  scripts/helpers/check_package_installed.sh
)

# Set executable permissions for the scripts
echo "Setting executable permissions for scripts..."
for script in "${scripts[@]}"; do
  sudo chmod +x "$script"
done
for helper in "${helpers[@]}"; do
  sudo chmod +x "$helper"
done

# Apply parallel downloads configuration for pacman
echo "Configuring parallel downloads for pacman..."
pacman_conf="/etc/pacman.conf"
if grep -q "^ParallelDownloads" "$pacman_conf"; then
  echo "ParallelDownloads is already configured."
else
  echo "Adding ParallelDownloads configuration to pacman.conf..."
  sudo sed -i '/\[options\]/a ParallelDownloads = 5' "$pacman_conf"
fi

# Run each script in the array
for script in "${scripts[@]}"; do
  echo "Running $script..."
  if ! ./"$script"; then
    echo "$script failed. Exiting."
    exit 1
  fi
done

# Clean up package cache
echo "Cleaning up package cache..."
sudo pacman -Scc --noconfirm

# Option to reboot the system
echo "Installation complete. Would you like to reboot the system? (yes/no)"
read -r answer
if [[ "$answer" =~ ^[Yy]es$ ]]; then
  echo "Rebooting the system..."
  reboot
else
  echo "Installation complete. Please reboot manually."
fi
