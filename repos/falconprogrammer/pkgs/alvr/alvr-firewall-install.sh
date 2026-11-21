#!/usr/bin/env bash
# Install the ALVR ufw application profile into /etc/ufw/applications.d/ when it is missing or differs from the packaged one
set -euo pipefail

script_directory="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
packaged_profile="$script_directory/../share/alvr/ufw-alvr"
installed_profile="/etc/ufw/applications.d/alvr"

if [[ ! -f "$packaged_profile" ]]; then
  echo "alvr-firewall-install: packaged profile not found at $packaged_profile" >&2
  exit 1
fi

if [[ -f "$installed_profile" ]] && cmp --silent "$packaged_profile" "$installed_profile"; then
  echo "ALVR ufw profile is up to date: $installed_profile"
  exit 0
fi

if [[ -f "$installed_profile" ]]; then
  echo "ALVR ufw profile differs from the packaged one, replacing $installed_profile"
else
  echo "ALVR ufw profile missing, installing $installed_profile"
fi

# Host sudo from PATH; a sudo inside the Nix store lacks the setuid bit
sudo install --mode=644 "$packaged_profile" "$installed_profile"

echo "Installed. Run 'sudo ufw allow alvr' to open the ports, or 'sudo ufw app update alvr' to refresh an existing rule."
