#!/bin/bash

# Update system and install essential packages
echo "🔧 Updating system package database..."
sudo pacman -Syy --noconfirm
sudo pacman -S archlinux-keyring --noconfirm

echo "📦 Installing KVM, QEMU, and related packages..."
sudo pacman -S --needed --noconfirm qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat dmidecode

echo "📦 Installing ebtables and iptables..."
sudo pacman -S --needed --noconfirm ebtables iptables

# Install libguestfs
echo "📦 Installing libguestfs..."
sudo pacman -S --needed --noconfirm libguestfs

# Start and enable libvirt service
echo "🔧 Enabling and starting libvirtd service..."
sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service

# Allow standard user accounts to manage KVM
echo "🔧 Configuring KVM for standard user accounts..."
sudo pacman -S --needed --noconfirm vim

# Configure libvirtd
sudo sed -i 's/^#unix_sock_group = .*/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf
sudo sed -i 's/^#unix_sock_rw_perms = .*/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf

# Add user to libvirt group
echo "🔧 Adding user to libvirt group..."
sudo usermod -a -G libvirt "$(whoami)"

# Restart libvirtd service
echo "🔧 Restarting libvirtd service..."
sudo systemctl restart libvirtd.service

# Enable nested virtualization (optional)
read -r -p "Do you want to enable nested virtualization? (y/n): " enable_nested
if [ "$enable_nested" == "y" ]; then
  echo "🔧 Enabling nested virtualization..."

  if grep -q "Intel" /proc/cpuinfo; then
    echo "🔧 Configuring Intel processor..."
    sudo modprobe -r kvm_intel
    sudo modprobe kvm_intel nested=1
    echo "options kvm-intel nested=1" | sudo tee /etc/modprobe.d/kvm-intel.conf
  elif grep -q "AMD" /proc/cpuinfo; then
    echo "🔧 Configuring AMD processor..."
    sudo modprobe -r kvm_amd
    sudo modprobe kvm_amd nested=1
    echo "options kvm-amd nested=1" | sudo tee /etc/modprobe.d/kvm-amd.conf
  else
    echo "❌ Unsupported processor type."
  fi
fi

echo "✅ KVM, QEMU, and Virt-Manager have been installed and configured."
