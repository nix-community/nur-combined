#!/bin/bash

# Check if necessary packages are installed
echo "Installing packages for snapper-rollback preparation..."
sudo pacman -S snapper snap-pac sudo base-devel --noconfirm

# Check if Snapper is already configured
if snapper list-configs | grep -q 'root'; then
  echo "Snapper is already configured."
else
  echo "Configuring Snapper for the root filesystem..."
  sudo umount /.snapshots/
  sudo rm -rf /.snapshots/
  sudo snapper -c root create-config /
  sudo mount -a
fi

# Check if snapper-rollback is already installed
if pacman -Qi snapper-rollback &> /dev/null; then
  echo "snapper-rollback is already installed."
else
  echo "Installing snapper-rollback..."
  yay -S snapper-rollback --noconfirm
fi

root_partition=$(findmnt -n -o SOURCE /)
# Check if /etc/snapper-rollback.conf is already configured
if [ -f /etc/snapper-rollback.conf ] && grep -q "dev = $root_partition" /etc/snapper-rollback.conf; then
  echo "snapper-rollback is already configured."
else
  # Configure snapper-rollback
  echo "Configuring snapper-rollback..."
  echo "[snapper-rollback]" | sudo tee /etc/snapper-rollback.conf > /dev/null
  echo "dev = $root_partition" | sudo tee -a /etc/snapper-rollback.conf > /dev/null
fi

# Check if a snapshot has already been created
if sudo snapper list | grep -q "backup: initial snapshot"; then
  echo "Initial snapshot already created."
else
  # Create a snapshot with Snapper
  echo "Creating a snapshot with Snapper..."
  sudo snapper create --description "backup: initial snapshot"
fi
