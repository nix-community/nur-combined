#!/bin/bash

# Update system and install core packages
echo "🛠️ Updating system and installing core packages..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed virtualbox virtualbox-host-modules-arch virtualbox-host-dkms --noconfirm

# Install necessary headers for dkms
echo "🔧 Installing necessary kernel headers..."
sudo pacman -S --needed linux-headers linux-lts-headers --noconfirm

# Sign modules (if using a custom kernel)
if [ -d "/lib/modules/$(uname -r)/kernel/misc" ]; then
  echo "🔑 Signing VirtualBox kernel modules..."
  sudo sh -c 'for module in /lib/modules/$(uname -r)/kernel/misc/{vboxdrv.ko,vboxnetadp.ko,vboxnetflt.ko}; do ./scripts/sign-file sha1 certs/signing_key.pem certs/signing_key.x509 $module; done'
else
  echo "🔒 No custom kernel detected. Skipping module signing."
fi

# Load VirtualBox kernel modules
echo "📦 Loading VirtualBox kernel modules..."
sudo modprobe vboxdrv

# Optionally, configure automatic module loading
echo "📜 Configuring module loading..."
sudo systemctl enable systemd-modules-load.service
sudo systemctl start systemd-modules-load.service

# USB access configuration
echo "🔌 Adding user to vboxusers group..."
sudo usermod -aG vboxusers "$USER"

# Install Guest Additions ISO (if needed)
echo "💻 Installing VirtualBox Guest Additions ISO..."
sudo pacman -S --needed virtualbox-guest-iso --noconfirm

# Install Extension Pack
echo "🧩 Installing VirtualBox Extension Pack..."
# Use this if you prefer the AUR package
# yay -S virtualbox-ext-oracle --noconfirm
# Or manually install if downloaded
# VBoxManage extpack install <path-to-extension-pack.vbox-extpack>

# Front-ends installation (optional)
echo "🗂️ Installing VirtualBox front-ends..."
sudo pacman -S --needed virtualbox-qt vboxwebsrv --noconfirm

# Wayland configuration (if applicable)
echo "🛡️ Configuring Wayland settings..."
gsettings get org.gnome.mutter.wayland xwayland-grab-access-rules
gsettings set org.gnome.mutter.wayland xwayland-grab-access-rules "['VirtualBox Machine']"

echo "🎉 VirtualBox installation and configuration completed!"
