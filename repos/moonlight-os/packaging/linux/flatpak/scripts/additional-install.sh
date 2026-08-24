#!/bin/sh

# User Service
mkdir -p ~/.config/systemd/user
cp "/app/share/helios/systemd/user/helios.service" "$HOME/.config/systemd/user/helios.service"
echo "Helios User Service has been installed."
echo "Use [systemctl --user enable helios] once to autostart Helios on login."

# Load uhid (DS5 emulation)
UHID=$(cat /app/share/helios/modules-load.d/60-helios.conf)
echo "Enabling DS5 emulation."
flatpak-spawn --host pkexec sh -c "echo '$UHID' > /etc/modules-load.d/60-helios.conf"
flatpak-spawn --host pkexec modprobe uhid

# Udev rule
UDEV=$(cat /app/share/helios/udev/rules.d/60-helios.rules)
echo "Configuring mouse permission."
flatpak-spawn --host pkexec sh -c "echo '$UDEV' > /etc/udev/rules.d/60-helios.rules"
echo "Restart computer for mouse permission to take effect."
