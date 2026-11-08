#!/bin/bash

# Install Bluetooth packages
echo "Installing Bluetooth packages..."
sudo pacman -S --noconfirm bluez bluez-utils

# Enable and start the Bluetooth service
echo "Enabling and starting the Bluetooth service..."
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

# Check Bluetooth service status
echo "Bluetooth service status:"
systemctl status bluetooth.service | grep Active

# Add the user to the bluetooth group (optional)
# This step grants the user permission to manage Bluetooth devices
echo "Adding the user to the bluetooth group..."
sudo usermod -aG lp "$USER"

# Bluetooth setup
echo "Scanning for Bluetooth devices..."
bluetoothctl -- power on
bluetoothctl -- scan on

echo "Bluetooth setup is complete."
echo "You can use the 'bluetoothctl' command to pair devices."
