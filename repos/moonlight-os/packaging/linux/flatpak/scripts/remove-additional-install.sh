#!/bin/sh

# User Service
systemctl --user stop helios
rm "$HOME/.config/systemd/user/helios.service"
systemctl --user daemon-reload
echo "Helios User Service has been removed."

# Remove rules
flatpak-spawn --host pkexec sh -c "rm /etc/modules-load.d/60-helios.conf"
flatpak-spawn --host pkexec sh -c "rm /etc/udev/rules.d/60-helios.rules"
echo "Input rules removed. Restart computer to take effect."
