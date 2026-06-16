#!/bin/bash

# Check if sddm is already installed
if pacman -Qi sddm &> /dev/null; then
  echo "SDDM is already installed."
else
  echo "Installing sddm and sddm-kcm..."
  sudo pacman -S sddm sddm-kcm --noconfirm

  # Enable the sddm service
  echo "Enabling the sddm service..."
  sudo systemctl enable sddm.service

  # Create a snapshot with Snapper
  echo "Creating a snapshot with Snapper..."
  sudo snapper create --description "backup: post-install sddm"
fi
